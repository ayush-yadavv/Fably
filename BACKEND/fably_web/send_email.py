import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart



def send_email(receiver_email, subject, body):
    sender_email = "fably.notification@gmail.com"
    password = "nhle twnl pyrz gthc"  # Use an app-specific password if using Gmail

    # Create the email
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject

    # Add body to the email
    msg.attach(MIMEText(body, 'html'))

    try:
        # Connect to the server
        server = smtplib.SMTP('smtp.gmail.com', 587)  # For Gmail
        server.starttls()  # Upgrade to a secure encrypted connection
        
        # Login to the email account
        server.login(sender_email, password)
        
        # Send the email
        server.sendmail(sender_email, receiver_email, msg.as_string())
        
        print("Email sent successfully!")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        server.quit()  # Always close the server

if __name__=="__main__":
    receiver_email = "fably.notification@gmail.com"
    subject = "Test Email from Python"
    body = "<h1>This is a <b>test</b> email sent from Python!</h1>"
    
    send_email(receiver_email, subject, body)
