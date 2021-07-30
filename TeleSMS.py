import io
import os
import json
import requests
import subprocess

FOLDER = ".TeleSMS/"
FILE_NAME = "Data.json"
PATH = FOLDER+FILE_NAME

CHAT_ID = int("YOUR_CHAT_ID") # Get your Telegram ID from here http://t.me/chatid_echo_bot
TOKEN = "TOKEN" # TeleSMSBot

def readSMS():
    output = subprocess.Popen(["termux-sms-list"], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output.wait()
    jsonS,_ = output.communicate()
    return json.loads(jsonS)

def readSMSTest():
    with open(FOLDER+"TestData.json") as json_file:
        return json.load(json_file)

def sendOnTelegram(messsage):
    text = "👤️ "+str(messsage['number'])+"\n🕝 "+str(messsage['received'])+" 🇮🇳\n💬 "+str(messsage['body'])
    url= "https://api.telegram.org/bot"+TOKEN+"/sendMessage?chat_id="+str(CHAT_ID)+"&text="+text
    r = requests.get(url,data=text.encode('utf-8'),headers={'Content-type': 'text/plain; charset=utf-8'}).json()
    return r['ok']

def main():
    # Check if folder is there
    if not os.path.exists(FOLDER):
        os.makedirs(FOLDER)

    if os.path.isfile(PATH) and os.access(PATH, os.R_OK):
        # checks if file exists
        print ("File exists and is readable")
        # Read SMSs from Inbox
        SMSs = readSMS()
        # Read All SMSs and Check if it's in file or not if not send it via Telegram
        with open(PATH) as json_file:
            data = json.load(json_file)
            for new_messsage in SMSs:
                flag = True
                for stored_messsage in data:
                    if new_messsage == stored_messsage:
                        # Match Found
                        flag = False
                if flag is True:
                    # Send via Telegram
                    if sendOnTelegram(new_messsage):
                        print("Sent: "+str(new_messsage)+"...")
        # Delete The Data.json
        os.remove(PATH)
        # Re-write Data.json
        with io.open(os.path.join(FOLDER, FILE_NAME), 'w') as db_file:
            db_file.write(json.dumps(SMSs))
    else:
        print ("Either file is missing or is not readable, creating file...")
        with io.open(os.path.join(FOLDER, FILE_NAME), 'w') as db_file:
            # Store SMSs in Data.json
            SMSs = readSMS()
            db_file.write(json.dumps(SMSs))

if __name__ ==  "__main__":
    main()
