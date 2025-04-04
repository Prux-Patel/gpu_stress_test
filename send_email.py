import smtplib
from email.message import EmailMessage

msg = EmailMessage()
msg.set_content("Benchmark Report attached")
msg["Subject"] = "GPU Benchmark Report"
msg["From"] = "your-email@gmail.com"
msg["To"] = "prakash.patel@cudoventures.com"

with open("benchmark_report.txt", "rb") as f:
    msg.add_attachment(f.read(), maintype="application", subtype="octet-stream", filename="benchmark_report.txt")

with open("mistral_benchmark.csv", "rb") as f:
    msg.add_attachment(f.read(), maintype="application", subtype="octet-stream", filename="mistral_benchmark.csv")

with open("llama3_benchmark.csv", "rb") as f:
    msg.add_attachment(f.read(), maintype="application", subtype="octet-stream", filename="llama3_benchmark.csv")

with open("gemma3_benchmark.csv", "rb") as f:
    msg.add_attachment(f.read(), maintype="application", subtype="octet-stream", filename="gemma3_benchmark.csv")

with open("gpu_test_log.txt", "rb") as f:
    msg.add_attachment(f.read(), maintype="application", subtype="octet-stream", filename="gpu_test_log.txt")

server = smtplib.SMTP("smtp.gmail.com", 587)
server.starttls()
server.login("prakash.patel@cudoventures.com", "dhbs ixny ehki atvp")
server.send_message(msg)
server.quit()

