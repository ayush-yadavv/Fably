import requests
from PIL import Image
from io import BytesIO

def check_image(url):
    try:
        # Send a GET request to the URL
        response = requests.get(url, stream=True)
        
        # Check if the status code is 200
        if response.status_code == 200:
            print("Response status is 200. Checking if it's an image...")
            
            # Attempt to open the response content as an image
            try:
                image = Image.open(BytesIO(response.content))
                print("The URL contains a valid image.")
                return True
            except Exception as e:
                print("The content is not a valid image.")
                return False
        else:
            print(f"Failed to fetch the URL. Status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"An error occurred while fetching the URL: {e}")
        return False

# Test the function
if __name__ == '__main__':
    url = "https://cdn.fashn.ai/c9d64623-b517-49ba-8c26-e19e74b856d5/output_0.png"
    if check_image(url):
        print("The URL is valid and contains an image.")
    else:
        print("The URL is either invalid or does not contain an image.")
