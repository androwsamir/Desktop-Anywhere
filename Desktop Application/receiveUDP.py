import socket
import pyautogui
import json
import win32api

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

def is_json_like_map(message):
    try:
        # Attempt to parse the message as JSON
        parsed_message = json.loads(message)
        # Check if the parsed message is a dictionary (similar to a map)
        return isinstance(parsed_message, dict)
    except json.JSONDecodeError:
        # If parsing fails, return False
        return False

def map_coordinates(mobile_x, mobile_y, mobile_width, mobile_height, desktop_width, desktop_height):
    # Calculate the ratio of movement along each axis
    x_ratio = desktop_width / mobile_width
    y_ratio = desktop_height / mobile_height

    # Map the coordinates to the desktop screen
    desktop_x = int(mobile_x * x_ratio)
    desktop_y = int(mobile_y * y_ratio)

    return desktop_x, desktop_y

def handle_mouse_movements(message):
    
    # Parse the JSON string to a Python dictionary
    data = json.loads(message)
    
    # Extract the x and y coordinates from the dictionary
    mobile_x = data["X"]
    mobile_y = data["Y"]

    mobile_width = 360.0
    mobile_height = 756.0

    desktop_width = win32api.GetSystemMetrics(0)
    desktop_height = win32api.GetSystemMetrics(1)

    desktop_x, desktop_y = map_coordinates(mobile_x, mobile_y, mobile_width, mobile_height, desktop_width, desktop_height)

    # Here, we'll just print the received coordinates for demonstration
    print(f"Received x: {desktop_x}, y: {desktop_y}")

    # Move the mouse to the specified coordinates
    pyautogui.moveTo(desktop_x, desktop_y, duration=0.1)

UDP_IP = "0.0.0.0"  # Listen on all available network interfaces
UDP_PORT = 8888
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))
c = 0
main_message = ''
while True:
    print(c)
    data, addr = sock.recvfrom(1024)  # Receive UDP message
    message = data.decode('utf-8')     # Decode the received data
    print("Received message:", message)
    c+=1
    if is_json_like_map(message=message):
        handle_mouse_movements(message)
    else:
        message = message.replace('"', '')

        message = get_new_char(message)
        print(f'Main Message : {main_message}')

        pyautogui.typewrite(message)


# pyautogui.moveTo(150, 150, duration=0.1)
# pyautogui.moveTo(15, 150, duration=0.1)

