import socket
import numpy as np
import struct
from mss import mss
import cv2
from PIL import Image
from pynput.mouse import Controller
import math
import time
import socket
import pyautogui
import json
import win32api
import subprocess
import psutil
import sys

def get_new_char(message):
    global main_message
    if message == 'Backspace':
        pyautogui.press('backspace')
        main_message = ''
        return ''
    if message == '':
        main_message = ''
    if main_message == '':
        if len(message) > 1:
            if message[len(message)-1] == 'n' and message[len(message)-2] == '\\':
                pyautogui.press('enter')
            
        main_message = message
        return message
    else:
        if len(message) > len(main_message):
            new_char = message[len(main_message)]
            if message[len(message)-1] == 'n' and message[len(message)-2] == '\\':
                pyautogui.press('enter')
                new_char = ''
            main_message = message
            return new_char
        elif len(message) < len(main_message):
            pyautogui.press('backspace')
            return ''
        elif len(message) == 0:
            main_message = ''

# def is_json_like_map(message):
#     try:
#         # Attempt to parse the message as JSON
#         parsed_message = json.loads(message)
#         # Check if the parsed message is a dictionary (similar to a map)
#         return isinstance(parsed_message, dict)
#     except json.JSONDecodeError:
#         # If parsing fails, return False
#         return False

def map_coordinates(mobile_x, mobile_y, mobile_width, mobile_height, desktop_width, desktop_height):
    # Calculate the ratio of movement along each axis
    x_ratio = desktop_width / mobile_width
    y_ratio = desktop_height / mobile_height

    # Map the coordinates to the desktop screen
    desktop_x = int(mobile_x * x_ratio)
    desktop_y = int(mobile_y * y_ratio)

    return desktop_x, desktop_y

def handle_mouse_movements(data, mobile_width, mobile_height):
    
    # Extract the x and y coordinates from the dictionary
    mobile_x = data["X"]
    mobile_y = data["Y"]

    desktop_width = win32api.GetSystemMetrics(0)
    desktop_height = win32api.GetSystemMetrics(1)

    desktop_x, desktop_y = map_coordinates(mobile_x, mobile_y, mobile_width, mobile_height, desktop_width, desktop_height)

    # Here, we'll just print the received coordinates for demonstration
    print(f"Received x: {desktop_x}, y: {desktop_y}")

    # Move the mouse to the specified coordinates
    pyautogui.moveTo(desktop_x, desktop_y, duration=0.1)

# Under Working
def close_idle_powershell():
    for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
        if proc.name() == 'powershell.exe' and proc.cmdline() == ['powershell.exe']:
            proc.terminate()
            print("Idle instance of PowerShell terminated.")
    #         return

    # Command to get the process ID of the previous instance of sendUDP.py
    get_pid_command = 'Get-Process | Where-Object {$_.ProcessName -eq "Python" -and $_.MainWindowTitle -eq "sendUDP.py"} | Select-Object -ExpandProperty Id'

    # Execute the command in PowerShell to get the process ID
    pid_output = subprocess.check_output(['powershell', '-Command', get_pid_command])

    # Check if the output is empty
    if not pid_output:
        print("No instances of sendUDP.py running in PowerShell.")
    else:
        # Extract the process ID from the output
        pid = int(pid_output.strip())

        # Command to close the previous instance of sendUDP.py using its process ID
        close_command = f'Stop-Process -Id {pid}'

        # Execute the command in PowerShell to close the previous instance
        subprocess.run(['powershell', '-Command', close_command])

    return

def get_powershell_process():
    # print('==========================================================')
    
    for proc in psutil.process_iter(['pid', 'name']):
        if 'powershell.exe' in proc.name():
            cmdline = proc.cmdline()
            # Assuming the last script is the last element in the command line arguments
            last_script = ''
            if len(cmdline) > 1:
                last_script = cmdline[-3]

            if last_script == 'sendUDP.py':
                return proc.pid
            # print(f'last process running : {last_script}')
            # print(f'process ID: {proc.pid}\nporcess Name: {proc.name()}\nusername : {proc.username}\nstatus : {proc.status}')
            # print('==========================//\\\\================================')
        
    # print('==========================================================')
    return None

def runUdp(mobileWidth, mobileHeight):
    bufferSize = 1024
    UDPServerSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
    UDPServerSocket.bind(('0.0.0.0', 8888))
    print("UDP server up and listening")
    
    while True:
        # try:
        bytesAddressPair = UDPServerSocket.recvfrom(bufferSize)
        message = bytesAddressPair[0]
        address = bytesAddressPair[1]

        clientMsg = "Message from Client:{}".format(message)
        clientIP = "Client IP Address:{}".format(address)
        print(f"{clientMsg}\n{clientIP}\n-----------------\n")
        # =========================================================================================================== #
        # Need to handle exception when user close liveView widget as close the current powershell that has corrupted and open another one
        
        #region Under Work
        if b'"Keyboard-Touchpad"' in message:
            message = message.decode('utf-8')
            data = json.loads(message)
            if "Keyboard-Touchpad" in data:
                if isinstance(data["Keyboard-Touchpad"], dict):
                    handle_mouse_movements(data=data['Keyboard-Touchpad'], mobile_height=mobileHeight, mobile_width=mobileWidth)
                else:
                    message = data['Keyboard-Touchpad']
                    message = message.replace('"', '')

                    message = get_new_char(message)
                    print(f'Main Message : {main_message}')

                    pyautogui.typewrite(message)
        else:
            try:
                send(UDPServerSocket, address)
            except:
                # Get the PID of the PowerShell process
                powershell_pid = get_powershell_process()
                if powershell_pid:
                    # Terminate the PowerShell process
                    psutil.Process(powershell_pid).terminate()
                
                # this command in comment to handle exceptions 
                # command = f'start powershell -NoExit python sendUDP.py {mobileWidth} {mobileHeight}'
                command = f'powershell -NoExit -Command "Start-Process -FilePath python -ArgumentList \\"sendUDP.py {mobileWidth} {mobileHeight}\\" -WindowStyle Normal"'

                try:
                    subprocess.Popen(command, shell=True, creationflags=subprocess.CREATE_NEW_CONSOLE)
                    print('Script started successfully!')
                except Exception as e:
                    print(f'Error: {e}')
                # global subprocess_pid
                # close_idle_powershell()
                # if subprocess_pid != '':
                #     # Command to close the previous instance of sendUDP.py using its process ID
                #     close_command = f'Stop-Process -Id {subprocess_pid}'

                #     # Execute the command in PowerShell to close the previous instance
                #     subprocess.run(['powershell', '-Command', close_command])
                # for process in psutil.process_iter(['pid', 'name', 'cmdline']):
                #     # Check if the process is PowerShell and its command line doesn't contain any script name
                #     if process.info['name'] == 'powershell.exe' and len(process.info['cmdline']) == 1:
                #         print(process.info['cmdline'])
                        # # Check CPU usage
                        # cpu_usage = process.cpu_percent(interval=0.1)
                        # if cpu_usage < 1:  # Adjust the threshold as needed
                        #     print(f"Closing PowerShell process with PID {process.info['pid']} as it's idle.")
                        #     process.kill()  # Terminate the process

                
                # subprocess_pid = process.pid

        # except:
        #     for process in psutil.process_iter(['pid', 'name', 'cmdline']):
        #         # Check if the process is PowerShell and its command line doesn't contain any script name
        #         if process.info['name'] == 'powershell.exe' and len(process.info['cmdline']) == 1:
        #             print(process.info['cmdline'])
            

        #endregion
 
def send(UDPServerSocket, address):
    print("start loop")
    frame, size = screenshot(10)
    print(size)
    UDPServerSocket.sendto(str.encode("size"), address)
    UDPServerSocket.sendto(struct.pack('!I', size), address)
 
    # Send the compressed image data in chunks
    chunk_size = 1024  # Adjust the chunk size as needed
 
    # Set timeout for socket operations
    UDPServerSocket.settimeout(0.08)  # 0.08 second timeout
 
    c=0
    for i in range(0, size, chunk_size):
        chunk = frame[i:i + chunk_size]
        UDPServerSocket.sendto(chunk, address)
 
        c+=1
        try:
            data, _ = UDPServerSocket.recvfrom(1024)
            if data == b'ACK':
                print(f"Chunk {c}/{math.ceil(size/chunk_size)} sent successfully")
        except socket.timeout:
            print(f"Timeout occurred while waiting for acknowledgment for chunk {c}/{math.ceil(size/chunk_size)}. Resending...")
            UDPServerSocket.sendto(chunk, address)  # Resend the chunk
 
    UDPServerSocket.sendto(str.encode("end"), address)
    UDPServerSocket.settimeout(50000)  # 50000 second timeout
    print("end loop\n\n\n")
    time.sleep(0.5)
 
def overlay_cursor_icon(image):
    cursor_position = Controller().position
    cursor_x, cursor_y = cursor_position
 
    # Draw a circle to represent the mouse cursor
    cursor_size = 8  # Adjust the size as needed
    cursor_color = (255, 255, 255)  # White color (you can change it)
 
    # Overlay the cursor icon onto the image
    image_array = np.array(image)
    cv2.circle(image_array, (cursor_x, cursor_y), cursor_size, cursor_color, 2) 
    return Image.fromarray(image_array)
 
def screenshot(quality=15):
    mon = {'top': 0, 'left': 0, 'width': 1920, 'height': 1080}
    sct = mss()
    sct_img = sct.grab(mon)
    img = Image.frombytes('RGB', (sct_img.size.width, sct_img.size.height), sct_img.rgb)
    img = overlay_cursor_icon(img)
    img_bgr = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
    _, jpeg = cv2.imencode('.jpg', img_bgr, [cv2.IMWRITE_JPEG_QUALITY, quality])
    img_bytes = jpeg.tobytes()
    return img_bytes, len(img_bytes)
 
 
 
if __name__ == "__main__":

    mobileWidth = float(sys.argv[1])  # First parameter
    mobileHeight = float(sys.argv[2])  # Second parameter

    main_message = ''
    # subprocess_pid = ''
    runUdp(mobileWidth, mobileHeight)