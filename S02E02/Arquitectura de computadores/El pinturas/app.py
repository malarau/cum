import numpy as np
import cv2, os, math
from PIL import Image

#----------------------------------------------------------------------------
# Created By  : Matias Lara
# Created Date: 05/12/2020
# ---------------------------------------------------------------------------

"""
        ####################################################################
        #   Por tiempo empleado, no se recomienda usar más de 600 líneas.  #
        #   600 líneas =                                                   #
        #                   ~ 1-2h compilación (?)                         #
        #   El tiempo de dibujado depende del largo del cuadrado a pintar. #
        #   Con largo = 8 y 600 líneas =                                   #
        #                   ~ 2h de dibujado                               #
        ####################################################################
"""

"""
    RECALCULA EL LARGO DE LA NUEVA IMAGEN EN PIXELES.
    DEFINE EL LARGO QUE TENDRÁ EL LADO MÁS LARGO DE LA IMAGEN.

    EJ: SI LARGER_SIDELARGER_SIDE = 34, ENTONCES
    340X200 PX, PASARÁ A SER ---> 34X20

    Aquello da 680 líneas de código llamando a la macro "rectangulo".
    Se utiliza una funnnción para juntar las celdas del mismo color dentro de una fila
    y así reducir la cantidad de líneas. El resultado depende de la imagen.
"""
LARGER_SIDE = 42

"""
    PX_SQUARE_LENGHT = EL LARGO DEL CUADRADO A PINTAR

    EMU8086 PINTARÁ USANDO LA MACRO VISTA: "RECTANGULO".
    POR DEFECTO SE ESPERA A QUE SIEMPRE PINTE UN CUADRADO A LA VEZ, 
    PERO SI EXISTEN 2 CUADRADOS CONTÍNUOS IGUALES EN UNA FILA, LOS UNE (get_8086_code()).
"""
PX_SQUARE_LENGHT = 6

"""
    LA IMAGEN A USAR
"""
# Imágenes // Ejemplos usados
IMAGE_MONALISA = "img/monalisa.jpg" # 32x? bloques de 5
IMAGE_LENA = "img/lena.jpg" # 30x30 bloques de 10
IMAGE_CR7 = "img/siuuu.jpg" # 31x31 bloques de 8
IMAGE_LOGO_CSGO = "img/logo_csgo.jpg" # 42x32 bloques de 6

IMAGE = IMAGE_LOGO_CSGO # <--- Reemplazar acá

"""
    ###########################################################################
"""

# Get every unique color on the image
def get_all_different_colors(image_grayscale, image_color):
    colors = []

    # How many different intensities:
    intensities = np.unique(image_grayscale)
    print("image_grayscale.shape ", image_grayscale.shape)
    print("len(intensities) ", len(intensities))

    for intensity in intensities:
        appareancesX, appareancesY  = np.where(image_grayscale == intensity) # Where to find that intensity
        # We only need one X,Y pair, just to get the color.
        colors.append( [image_color[appareancesX[0], appareancesY[0]][0], image_color[appareancesX[0], appareancesY[0]][1], image_color[appareancesX[0], appareancesY[0]][2]] )
    return colors

# Text file to use
TXT_TRANSLATOR = "macro_8086.txt"

# Lines to paste on our code
LINE_TO_START_WRITING = 65
def create_txt_file(macro_lines):
    with open(TXT_TRANSLATOR, "w") as f :
        for line in macro_lines:
            f.write("{}\n". format(line))

    # Open the file to paste into emu8086
    os.startfile(TXT_TRANSLATOR)

# Larger side of the resized image in px
def resize_image(image_color):
    new_dimentions = ()

    if image_color.shape[0] > image_color.shape[1]: # Portrait image
        new_dimentions = ( round((image_color.shape[1]*LARGER_SIDE)/image_color.shape[0]), LARGER_SIDE ) # For some reason, are inverted
    elif image_color.shape[0] < image_color.shape[1]: # Landscape image
        new_dimentions = ( LARGER_SIDE, round((image_color.shape[0]*LARGER_SIDE)/image_color.shape[1]) ) # For some reason, are inverted
    else: # Square
        new_dimentions = (LARGER_SIDE, LARGER_SIDE)

    # resize image
    resized = cv2.resize(image_color, new_dimentions, interpolation=cv2.INTER_AREA)

    print(resized.shape)
    
    return resized

# Format:
# r, g, b, hexa_r, hexa_g, hexa_b, hexa_color
def get_palette():
    palette = [] # The index is the actual vga value
    with open("vga-palette.txt", "r") as file:
        for line in file:
            color_values = line.split(",")
            palette.append([ int(color_values[0]), int(color_values[1]), int(color_values[2]) ])
    return palette

# For every different color detected, calculate the most similar value on VGA palette.
def get_rgb_to_vga_traduction_dict(image, palette):
    vga_values = np.zeros(shape=(image.shape[0], image.shape[1])) # THE ACTUAL NUMBER THAT YOU USE ON 8086

    for x in range(0, image.shape[0]):
        for y in range(0, image.shape[1]):
            best_dist = 2**31
            best_vga = []
            # Using Euclidean distance to calculate difference between values
            for vga in palette:
                dist = math.sqrt( (image[x][y][0]-vga[0])**2 + (image[x][y][1]-vga[1])**2 + (image[x][y][2]-vga[2])**2 )
                if dist < best_dist:
                    best_dist = dist 
                    best_vga = vga
            # Replace the best match
            vga_values[x][y] = int(palette.index(best_vga))
    
    return vga_values

def get_index_VGA_color(palette, color):
    for i in range(0, len(palette)):
        if palette[i][0] == color[0] and palette[i][1] == color[1] and palette[i][2] == color[2]:
            return i
    return 0

# https://stackoverflow.com/questions/69062479/how-to-speed-up-color-quantization-via-kmeans-clustering
"""
    im_pil.quantize: Convert the image to 'P' mode with the specified number of colors.
"""
def color_quantize_fast(image, K):
    img = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    im_pil = Image.fromarray(np.uint8(img))
    im_pil = im_pil.quantize(K, None, 0, None)
    # cv2.cvtColor(np.array(im_pil.convert("RGB")), cv2.COLOR_RGB2BGR) 
    return np.array(im_pil.convert("RGB")) # cv2.COLOR_RGB2BGR

def get_8086_code(image_reduced_resized, VGA_values):
    
    """
    # WORKING BUT = LINEAR, DOES NOT CHECK IF CAN ACUMULATE CELLS TO REDUCE NUMBERS OF LINES

    lines_to_write = []
    lado = 5
    lado_x_offset = 25
    lado_y_offset = 25
    for row in range(0, image_reduced_resized.shape[0]):
        for col in range(0, image_reduced_resized.shape[1]):
            # rectangulo lado_offset, lado_offset, lado, lado, color
            current_x = lado_x_offset + col*lado
            current_y = lado_y_offset + row*lado
            color = int(VGA_values[row][col])
            lines_to_write.append("rectangulo {}, {}, {}, {}, {}".format(current_x, current_y, lado, lado, color))
    create_txt_file(lines_to_write)
    """

    lines_to_write = []
    lado_y_offset = 25
    # Iterate
    for row in range(0, image_reduced_resized.shape[0]): # Row
        # Get first
        last_color = int(VGA_values[row][0])
        last_x = 25
        counter = 1
        for col in range(1, image_reduced_resized.shape[1]): # Col
            # We are moving thought the row, for every column

            # Check if color is the same
            color = int(VGA_values[row][col])
            if last_color == color: 
                counter = counter + 1
            else:
                finishing_x_point = (counter)*PX_SQUARE_LENGHT
                current_y = lado_y_offset + row*PX_SQUARE_LENGHT
                lines_to_write.append("\trectangulo {}, {}, {}, {}, {}".format(last_x, current_y, PX_SQUARE_LENGHT, finishing_x_point, last_color))
                # Reset?
                # Dont reset if is the last item of the row
                if col != image_reduced_resized.shape[1]-1:
                    last_color = int(VGA_values[row][col])
                last_x = finishing_x_point+last_x
                counter = 1

        # If there are remaining in the last one 
        if last_color == color: # If the last is the same
            #counter = counter + 1
            finishing_x_point = (counter)*PX_SQUARE_LENGHT
            current_y = lado_y_offset + row*PX_SQUARE_LENGHT
            lines_to_write.append("\trectangulo {}, {}, {}, {}, {}".format(last_x, current_y, PX_SQUARE_LENGHT, finishing_x_point, last_color))
        else: # If the last of the row is not the same color
            finishing_x_point = PX_SQUARE_LENGHT
            current_y = lado_y_offset + row*PX_SQUARE_LENGHT
            lines_to_write.append("\trectangulo {}, {}, {}, {}, {}".format(last_x, current_y, PX_SQUARE_LENGHT, finishing_x_point, color))

    create_txt_file(lines_to_write)

# 1.- ORIGINAL IMAGE
# 2.- REDUCE COLORS FORMING GROUPS (KMEANS)
# 3.- REDUCE IMAGE SIZE
def reduce_colors():
    # Original
    image_original = cv2.imread(IMAGE, cv2.IMREAD_UNCHANGED)

    # From 256 gray intensities to -> 256/K = 16 intensities
    K = 16 
    image_reduced = color_quantize_fast(image_original, K)

    # Grayscale resized image
    #image_reduced_grayscale = cv2.cvtColor(image_reduced, cv2.COLOR_BGR2GRAY) # 2^4 bit image
    # How many different colors
    #colors_rgb = get_all_different_colors(image_reduced_grayscale, image_reduced)

    # Resized (small, very)
    image_reduced_resized = resize_image(image_reduced)

    # GET THE VGA PALETTE -> vga-palette.txt
    palette = get_palette()

    # The color traduction
    VGA_values = get_rgb_to_vga_traduction_dict(image_reduced_resized, palette)

    # Create a txt with the lines to pase on emu8086
    get_8086_code(image_reduced_resized, VGA_values)

    #cv2.imshow("Reduced deph color", image_reduced)
    #cv2.imshow("Reduced-deph color resized ", image_reduced_resized)
    #cv2.waitKey(0)
    #cv2.destroyAllWindows()
    #cv2.imwrite(os.path.join(os.getcwd(), 'image_reduced_resized.jpg'), image_reduced_resized)

if __name__ == "__main__":
    reduce_colors()
    