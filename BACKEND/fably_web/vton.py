import requests
import json
import config
#import logging

#logging.basicConfig(level=logging.DEBUG)

def tryOn(garment_url, person_url, webhook):
    #logging.debug(config.FASHN_API_KEY)
    print(config.FASHN_API_KEY)
    webhook = "https://webhook.site/a6c44ce0-540e-402b-adfb-ba6bf0d0aabb"

    try:
        response = requests.post(
            f"https://api.fashn.ai/v1/run?webhook_url={webhook}",
            headers={
                "Authorization": f"Bearer {config.FASHN_API_KEY}", 
                "Content-Type": "application/json"
                },
            json={
                "model_image": person_url,
                "garment_image": garment_url,
                "category": "auto",
            },
        )


        json_response = {}

        try:
            json_response = json.loads(response.text)
            print(json_response)
        except json.JSONDecodeError:
            print("Failed to decode JSON:", response.text)
            return "Error"

        print(response.text)
        if json_response['error'] != None:
            return "Error"
        print("Success")
        print(json_response['error'])
        return json_response['id']
    
    except Exception as e:
        print(e)
        return "Error"

if __name__ == '__main__':
    person_url = "https://res.cloudinary.com/dcmelcukm/image/upload/v1742184803/bad-focus-1_cf74ta.jpg"
    garment_url = "https://res.cloudinary.com/dldgeyki5/image/upload/v1740418153/t2ovnna9jteiciupapw9.jpg"
    webhook = "https://webhook.site/a6c44ce0-540e-402b-adfb-ba6bf0d0aabb"
    tryOn(garment_url, person_url, webhook)
