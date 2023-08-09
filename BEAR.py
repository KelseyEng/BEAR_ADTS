from octorest import OctoRest

def make_client(URL = "", API_KEY = ""):
    try:
        client = OctoRest(url=URL, apikey=API_KEY)
        return client
    except Exception as e:
        print(e)

def get_version(): # ex: $ python -c 'import BEAR; BEAR.get_version()'
    client = make_client()
    message = "You are using OctoPrint v" + client.version['server']
    print(message)

def get_printer_info(): # ex: $ python -c 'import BEAR; BEAR.get_printer_info()'
    try:
        client = make_client()
        message = ""
#         message += str(client.version) + "\n"
#         message += str(client.job_info()) + "\n"
        printing = client.printer()['state']['flags']['printing']
        if printing:
            message += "Currently printing!"
        else:
            message += "Not currently printing..."
        print(message)
    except Exception as e:
        print(e)
        
def upload_gcode(file): # ex: $ python -c "import BEAR; BEAR.upload_gcode('test.gcode')"
    try: 
        client = make_client()
        client.upload(file)
        print("File Uploaded Sucessfully!")
    except:
        print("File Upload Failed!!")
    quit()

def start_gcode(file): # ex: $ python -c "import BEAR; BEAR.start_gcode('test.gcode')"
    try: 
        client = make_client()
        client.select(file,print=True) #Change print to True for actual printing
        #client.start()
        print("Print Started Sucessfully!")
    except:
        print("Print Start Failed!!")
    
def get_bed_temp(): # ex: $ python -c 'import BEAR; BEAR.get_bed_temp()'
    try: 
        client = make_client()
        bed_temp = client.bed()
        message = f"Current Bed Temperature is: {bed_temp['bed']['actual']}\nCurrent Bed Target is: {bed_temp['bed']['target']}"
        print(message)
    except:
        print("Failed to Get Bed Temperature!!")

def cancel_print():
    try: 
        client = make_client()
        client.cancel()
        print("cancel command sent")
    except:
        print("Failed to CANCEL!!") 