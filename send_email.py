import smtplib
from email.message import EmailMessage

msg = EmailMessage()
msg.set_content("Benchmark Report attached")
msg["Subject"] = "GPU Benchmark Report"
msg["From"] = "your-email@gmail.com"
msg["To"] = "prakash.patel@cudoventures.com"

with open("benchmark_report.txt", "rb") as f:
    msg.add_attachment(f.read(), maintype="application", subtype="octet-stream", filename="benchmark_report.txt")

server = smtplib.SMTP("smtp.gmail.com", 587)
server.starttls()
server.login("prakash.patel@cudoventures.com", "ubtj iyxf mqjo jldo")
server.send_message(msg)
server.quit()
