import shutil  # For copying files
from PIL import Image
import os
from io import BytesIO
from gradio_client import Client, handle_file

def create_blank_white_png_like(image_path, output_path="blank_white.png"):
    """
    Takes an image, converts it to PNG if needed, gets its size,
    and creates a blank white PNG of the same size.

    Args:
        image_path (str): Path to the input image file.
        output_path (str, optional): Path to save the blank white PNG.
                                     Defaults to "blank_white.png".

    Returns:
        tuple or None: A tuple containing (original_png_path, blank_white_png_path) if successful,
                       None if an error occurred.
    """
    try:
        # Open the image using Pillow
        img = Image.open(image_path)
        original_png_path = image_path  # Assume original path for now

        # Check if the image is already PNG
        if img.format != 'PNG':
            print(f"Image is not PNG, converting from {img.format} to PNG...")
            # Create a new path for the converted PNG
            original_png_path_base, original_png_path_ext = os.path.splitext(image_path)
            original_png_path = original_png_path_base + "_converted.png"

            # Convert to PNG and save
            img.save(original_png_path, format='PNG')
            print(f"Converted PNG saved to: {original_png_path}")

        # Get the size of the image (width, height) - using the potentially converted PNG now
        img_png = Image.open(original_png_path)  # Open the PNG to ensure we are working with PNG size
        width, height = img_png.size
        print(f"PNG Image size: {width}x{height}")

        # Create a new blank white PNG image of the same size
        blank_image = Image.new('RGB', (width, height), 'white')  # 'white' is equivalent to (255, 255, 255)

        # Save the blank white image as PNG
        blank_white_png_path = output_path
        blank_image.save(blank_white_png_path, 'PNG')
        print(f"Blank white PNG image created at: {blank_white_png_path}")
        return original_png_path, blank_white_png_path

    except FileNotFoundError:
        print(f"Error: Image file not found at: {image_path}")
        return None
    except Exception as e:
        print(f"An error occurred: {e}")
        return None
def tryOn(root_folder):
    # --- Image Paths ---
    input_image_path = f"{root_folder}/inputs/person.png"  # <--- REPLACE WITH PATH TO YOUR PERSON IMAGE
    garment_image_path = f"{root_folder}/inputs/cloth.png"  # <--- REPLACE WITH PATH TO YOUR GARMENT IMAGE
    output_blank_png = f"{root_folder}/outputs/blank_white_output.png"

    # --- Check if input files exist ---
    if not os.path.exists(input_image_path):
        print(f"Error: Person image file not found at: '{input_image_path}'")
    elif not os.path.exists(garment_image_path):
        print(f"Error: Garment image file not found at: '{garment_image_path}'")
    else:
        # --- Create PNG and Blank White Image ---
        image_paths = create_blank_white_png_like(input_image_path, output_blank_png)

        if image_paths:
            PATH1, PATH2 = image_paths  # PATH1: PNG person image, PATH2: blank white PNG
            PATH3 = garment_image_path  # PATH3: Garment image path

            print("\n--- Calling Gradio Client ---")
            try:
                client = Client("zhengchong/CatVTON")

                result = client.predict(
                    person_image={
                        "background": handle_file(PATH1),
                        "layers": [handle_file(PATH2)],
                        "composite": handle_file(PATH1)
                    },
                    cloth_image=handle_file(PATH3),
                    cloth_type="upper",  # or "lower", "overall" - adjust as needed
                    num_inference_steps=50,
                    guidance_scale=2.5,
                    seed=42,
                    show_type="result only",
                    api_name="/submit_function"
                )

                print("\nGradio Client Result:")
                print(result)

                # --- Save the output file to the same directory as app.py ---
                if result:
                    # Get the current directory (where app.py is located)
                    current_directory = os.path.dirname(os.path.abspath(__file__))
                    # Define the destination path for the output file
                    output_file_name = f"{root_folder}/outputs/output_image.webp"
                    destination_path = os.path.join(current_directory, output_file_name)
                    # Copy the file from the temporary directory to the current directory
                    shutil.copy(result, destination_path)
                    print(f"Output file saved to: {destination_path}")
                    return "Success"

            except Exception as e_gradio:
                print(f"Error during Gradio Client call: {e_gradio}")
                return f"Error during Gradio Client call: {e_gradio}"
        else:
            print("Failed to create PNG or blank white image. Cannot proceed with Gradio client.")
            return "Image Issue"

if __name__ == '__main__':
    tryOn()
