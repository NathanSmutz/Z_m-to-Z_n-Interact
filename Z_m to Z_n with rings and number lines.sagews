︠2026b35e-c4a9-4f19-83ef-6c6a001902cf︠
from math import fmod
@interact
def line_drawing(Function = 4 * x, Domain_Modulus = 12, Range_Modulus = 6, Side_By_Side = False, Proportionally_Sized = True):
    X                = 0    # x-coordinate index for point tupples
    Y                = 1    # y-coordinate index for point tupples
    RADIUS           = 2        #Default radius
    DOMAIN_RADIUS    = Domain_Modulus if Proportionally_Sized else 1 if Side_By_Side else 1.61803398875    #Golden Ratio
    RANGE_RADIUS     = Range_Modulus  if Proportionally_Sized else 1
    MAX_RADIUS       = max(DOMAIN_RADIUS, RANGE_RADIUS)

    DOMAIN_CENTER    = (5,0)
    RANGE_CENTER     = (5 + DOMAIN_RADIUS + RANGE_RADIUS + MAX_RADIUS * 0.61803398875 , 0) if Side_By_Side else (5,0)

    DOM_LINE_HEIGHT  = DOMAIN_CENTER[Y] - MAX_RADIUS * golden_ratio
    RNG_LINE_HEIGHT  = DOM_LINE_HEIGHT + DOM_LINE_HEIGHT / (golden_ratio * 2)
    MAX_LINE_LENGTH  = abs(RANGE_CENTER[X] + RANGE_RADIUS - (DOMAIN_CENTER[X] - DOMAIN_RADIUS)) if Side_By_Side else 2 * MAX_RADIUS
    LINE_TAIL_X      = DOMAIN_CENTER[X] - DOMAIN_RADIUS

    LABEL_DISTANCE   = .07 * MAX_RADIUS#min(Domain_Modulus, Range_Modulus)
    UNDEFINED_SYMBOL = "ud"


    SOLARIZED_ACCENT = {'yellow': '#b58900', 'orange': '#cb4b16', 'red': '#dc322f', 'magenta': '#d33682',
                        'violet': '#6c71c4', 'blue': '#268bd2', 'cyan': '#2aa198', 'green': '#859900'}
    SOLARIZED_COLORS = [SOLARIZED_ACCENT[i] for i in
                        ('red', 'orange', 'yellow', 'green', 'cyan', 'blue', 'violet', 'magenta')]
    #SOLARIZED_COLORS = [SOLARIZED_ACCENT[i] for i in
    #                    ('red','magenta', 'violet', 'blue', 'cyan', 'green', 'yellow', 'orange')]
    #COLORS           = ("red","orange","yellow","greenyellow","green","cyan","blue","purple")
    #COLORS           = ("black","red","green","blue") #Dark colors for better contrast
    COLORS           = SOLARIZED_COLORS
    NUM_COLORS       = len(COLORS)
    CIRCLE_COLOR     = '#93a1a1' #'#eee8d5' #


    def num_to_radians(num, modulus):
        return pi/2 - 2  * pi * num/modulus     # "pi/2 -" allows for plotting points clockwise from pi/2

    def radians_to_point(radians, center_point, radius):
        return (center_point[X] + radius * cos(radians),
                center_point[Y] + radius * sin(radians))

    def num_to_point(num, modulus = Domain_Modulus, center_point = DOMAIN_CENTER, radius = RADIUS):
        return radians_to_point(num_to_radians(num, modulus), center_point, radius)

    def make_graphic_object(i):
        """Creates a graphic for each point"""
        current_color    = COLORS[i%NUM_COLORS]
        tail             = num_to_point(i, Domain_Modulus, DOMAIN_CENTER, DOMAIN_RADIUS)
        try:# Check for division by Zero
            head         = num_to_point(Function(x = i), Range_Modulus, RANGE_CENTER, RANGE_RADIUS)
        except:
            head = UNDEFINED_SYMBOL

        if type(head) == str:
            graphic_object = text(head, tail, color = current_color)
        elif head == tail:
            graphic_object = circle(num_to_point(i,Range_Modulus, RANGE_CENTER, RANGE_RADIUS + LABEL_DISTANCE),
                                    LABEL_DISTANCE, color = current_color, thickness = 2)
        else:
            graphic_object = arrow(tail, head , color = current_color, width = 1, arrowsize = 4)

        return graphic_object

    def number_ring(modulus, center_point, radius = RADIUS):
        def neg_if_inner(radius):
            """ Helps to bring labels inside a circle if the circle is inside the other one"""
            return -1 if radius < MAX_RADIUS else 1

        return [text(str(i), \
                     num_to_point(i, modulus, center_point, radius + neg_if_inner(radius) * LABEL_DISTANCE), \
                     color = 'black', zorder = 10)#COLORS[i%NUM_COLORS])
                for i in xrange(ceil(modulus))] \
                + [circle(center_point, radius, color = CIRCLE_COLOR, zorder = -1)] \
                + [point(num_to_point(i,modulus,center_point, radius), color = 'black', zorder=3) for i in xrange(ceil(modulus))]

    def number_lines():
        max_modulus = max(Domain_Modulus, Range_Modulus)

        def pos_fmod(x, modulus):
            return fmod(x, modulus) if x >= 0 else modulus + fmod(x, modulus)

        def num_to_line_x(num):
            return LINE_TAIL_X + MAX_LINE_LENGTH * num/max_modulus

        def make_arrow(num):
            try:
                return arrow((num_to_line_x(i), DOM_LINE_HEIGHT),(num_to_line_x(pos_fmod(Function(x = i), Range_Modulus)), RNG_LINE_HEIGHT),
                         color = COLORS[i%NUM_COLORS] , width = 1, arrowsize = 4 )
            except:
                return text(UNDEFINED_SYMBOL, (num_to_line_x(i), DOM_LINE_HEIGHT - LABEL_DISTANCE))

        return [line(((LINE_TAIL_X, DOM_LINE_HEIGHT),(num_to_line_x(Domain_Modulus),DOM_LINE_HEIGHT )), color = CIRCLE_COLOR),
                line(((LINE_TAIL_X, RNG_LINE_HEIGHT),(num_to_line_x(Range_Modulus),RNG_LINE_HEIGHT )), color = CIRCLE_COLOR)] \
                + [text(str(i), (num_to_line_x(i), DOM_LINE_HEIGHT + LABEL_DISTANCE), color = 'black')
                 for i in xrange(ceil(Domain_Modulus))] \
                + [text(str(i), (num_to_line_x(i), RNG_LINE_HEIGHT - LABEL_DISTANCE), color = 'black')
                 for i in xrange(ceil(Range_Modulus))] \
                + [point((num_to_line_x(i), DOM_LINE_HEIGHT), color = 'black', zorder = 3)
                 for i in xrange(ceil(Domain_Modulus))] \
                + [point((num_to_line_x(i), RNG_LINE_HEIGHT), color = 'black', zorder = 3)
                 for i in xrange(ceil(Range_Modulus))] \
                + [make_arrow(i) for i in xrange(ceil(Domain_Modulus))]


    # Actual processing starts here
    objects_to_plot = map(make_graphic_object, xrange(ceil(Domain_Modulus))) \
                        + number_ring(Domain_Modulus, DOMAIN_CENTER, DOMAIN_RADIUS) \
                        + number_ring(Range_Modulus, RANGE_CENTER, RANGE_RADIUS) \
                        + number_lines()

    return reduce(lambda x, y: x+y, objects_to_plot ).show( aspect_ratio = 1, axes = false)
︡358a7072-05b9-4c12-9291-96eec35d5ffc︡{"interact":{"style":"None","flicker":false,"layout":[[["Function",12,null]],[["Domain_Modulus",12,null]],[["Range_Modulus",12,null]],[["Side_By_Side",12,null]],[["Proportionally_Sized",12,null]],[["",12,null]]],"id":"24334cb7-8fab-44c1-ad11-ae88fcc3c6e6","controls":[{"control_type":"input-box","default":"4*x","label":"Function","nrows":1,"width":null,"readonly":false,"submit_button":null,"var":"Function","type":null},{"control_type":"input-box","default":12,"label":"Domain_Modulus","nrows":1,"width":null,"readonly":false,"submit_button":null,"var":"Domain_Modulus","type":null},{"control_type":"input-box","default":6,"label":"Range_Modulus","nrows":1,"width":null,"readonly":false,"submit_button":null,"var":"Range_Modulus","type":null},{"default":false,"var":"Side_By_Side","readonly":false,"control_type":"checkbox","label":"Side_By_Side"},{"default":true,"var":"Proportionally_Sized","readonly":false,"control_type":"checkbox","label":"Proportionally_Sized"}]}}︡
︠8cefd5c3-426f-4014-976c-5583d3b08e78︠









