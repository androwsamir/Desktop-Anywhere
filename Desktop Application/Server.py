import base64
import subprocess
import re
import numpy as np
import cv2
from pynput.mouse import Controller
import psutil
import pyautogui
from flask import Flask, request, render_template, Response, jsonify
# import vncsdk
# from vidstream import StreamingServer, ScreenShareClient, CameraClient
import socketio
import requests
import io
from io import BytesIO
import threading
import socket
from mss import mss
import cv2
import os
from PIL import Image
import numpy as np
from time import time
import subprocess
# from screeninfo import get_monitors
import ctypes
import sys

class Server:

    def __init__(self):
        self.app = Flask(__name__)
        self.last_click_time = 0
        self.publicIP = self.get_public_ip()
        print(self.publicIP)
        # self.adminPrivilage()
        # static = StaticIP()

        # self.check_port_open(8888)

    def getPublicIP(self):
        return self.publicIP

    def adminPrivilage(self):
        try:
            if ctypes.windll.shell32.IsUserAnAdmin():
                print("gggggg")
            else:
                self.execute_with_admin_privileges()

        except Exception as e:
            print("Exception:", e)
            return False

    def execute_with_admin_privileges(self):
        try:
            sys.argv = ['D:\\01-University Courses\\04-Fourth Year\\graduationProject\\Code\\Desktop_Anywhere\\StaticIP.py']
            ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable,
                                                subprocess.list2cmdline(sys.argv),
                                                None, 1)
        except Exception as e:
            print("Exception:", e)

    def get_public_ip(self):
        try:
            response = requests.get('https://httpbin.org/ip')
            if response.status_code == 200:
                data = response.json()
                return data['origin']
            else:
                return "Failed to retrieve public IP"
        except Exception as e:
            return str(e)

    def extract_word_with_pattern(self, text, words):
        for word in words:
            # Search for the pattern in the text
            match = re.search(word, text)

            if match:
                # Extract the matched word
                matched_word = match.group(0)
                return matched_word

    def check_port_open(self, port):

        data = {
            'port': port,
            'IP': self.publicIP
        }

        headers = {
            'Host': 'canyouseeme.org',
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/112.0',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.5',
            'Accept-Encoding': 'gzip, deflate',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Origin': 'https://canyouseeme.org',
            'Referer': 'https://canyouseeme.org/?q=80',
            'Upgrade-Insecure-Requests': '1',
            'Sec-Fetch-Dest': 'document',
            'Sec-Fetch-Mode': 'navigate',
            'Sec-Fetch-Site': 'same-origin',
            'Sec-Fetch-User': '?1',
            'Te': 'trailers',
            'Connection': 'close',
        }

        words = ['Success', 'Error']

        try:
            # Send an HTTP request to canyouseeme.org with the port number
            response = requests.get(f'https://canyouseeme.org/?q={port}')
            if response.status_code == 200:
                response1 = requests.post('https://canyouseeme.org/', headers=headers, data=data)
                matched_word = self.extract_word_with_pattern(response1.text, words)
                print(matched_word)
            else:
                return "Failed to check port status"
        except Exception as e:
            return str(e)

    def overlay_cursor_icon(self, image):
        cursor_position = Controller().position
        cursor_icon = cv2.imread('Icons/cursor.jpeg')
        cursor_x, cursor_y = cursor_position

        # Get the dimensions of the cursor icon image
        icon_height, icon_width, _ = cursor_icon.shape

        # Determine the position to overlay the cursor icon on the screen image
        top_y = cursor_y - icon_height // 2
        left_x = cursor_x - icon_width // 2

        # Ensure that the cursor icon does not go outside the screen boundaries
        top_y = max(top_y, 0)
        left_x = max(left_x, 0)

        # Overlay the cursor icon onto the image
        image_array = np.array(image)
        image_array[top_y:top_y + icon_height, left_x:left_x + icon_width] = cursor_icon
        return Image.fromarray(image_array)

    def generate_frames(self):
        mon = {'top': 0, 'left': 0, 'width': 1920, 'height': 1080}

        with self.app.app_context():
            while True:
                sct = mss()
                sct_img = sct.grab(mon)
                img = Image.frombytes('RGB', (sct_img.size.width, sct_img.size.height), sct_img.rgb)
                img = self.overlay_cursor_icon(img)
                img_bgr = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
                _, jpeg = cv2.imencode('.jpg', img_bgr)
                frame = jpeg.tobytes()
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

    def run(self, serverPassword):
        @self.app.route('/')
        def index():
            return render_template('index.html')

        @self.app.route('/video')
        def video():
            return Response(self.generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

        @self.app.route('/move-mouse', methods=['POST'])
        def move_mouse():
            print('here')
            data = request.get_json()
            if 'x' in data and 'y' in data:
                x = data['x']
                y = data['y']
                pyautogui.moveTo(x, y)
            return 'OK'

        @self.app.route('/api/fetch_password', methods=['POST'])
        def fetch_password():
            data = request.get_json()

            # Assuming the JSON contains a 'password' field
            password = data.get('password')

            if serverPassword == password:
                return 'OK'

        @self.app.route('/transfer_partition/', methods=['GET'])
        def transfer_partition():
            target = request.args.get('target')
            colon_index = target.find(':')

            # Check if the colon is found
            if colon_index != -1:
                # Create a new string with a backslash inserted after the colon
                target = target[:colon_index + 1] + '\\' + target[colon_index + 1:]

            if target == 'all':
                partitions = []
                for disk in psutil.disk_partitions():
                    drive = disk.device
                    partitions.append(drive)

                return jsonify(partitions)
            else:
                directories = []
                files = []
                content = {}
                if os.path.isdir(target):
                    contents = os.listdir(target)
                    for item in contents:
                        item_path = os.path.join(target, item)
                        if os.path.isdir(item_path):
                            directories.append(item) 
                        else:
                            files.append(item)
                content['dir'] = directories
                content['files'] = files

                return jsonify(content)

        @self.app.route('/click-mouse', methods=['POST'])
        def click_mouse():
            data = request.get_json()
            if 'x' in data and 'y' in data:
                x = data['x']
                y = data['y']
                current_time = time()
                time_since_last_click = current_time - self.last_click_time

                if time_since_last_click < 0.3:
                    pyautogui.doubleClick(x, y)
                else:
                    pyautogui.click(x, y)

                self.last_click_time = current_time

            return 'OK'

        @self.app.route('/start-UDP', methods=['POST'])
        def start_udp():
            data = request.get_json()
            screenWidth = data['width']
            screenHeight = data['height']

            # this command in comment to handle exceptions 
            # command = f'start powershell -NoExit python sendUDP.py {screenWidth} {screenHeight}'
            command = f'powershell -NoExit -Command "Start-Process -FilePath python -ArgumentList \\"sendUDP.py {screenWidth} {screenHeight}\\" -WindowStyle Normal"'
            
            try:
                # Execute the command
                subprocess.Popen(command, shell=True)
                return 'Script started successfully!'
            except Exception as e:
                return f'Error: {e}'

        return self.app

# screenshot = pyautogui.screenshot()
# frame = cv2.cvtColor(np.array(screenshot), cv2.COLOR_RGB2BGR)
# _, buffer = cv2.imencode('.jpg', frame)
# frame = buffer.tobytes()
#
# # Yield the frame data
# yield (b'--frame\r\n'
#        b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

# def generate_frames(self):
    #     screen_capture = cv2.VideoCapture(0)
    #     while True:
    #         success, frame = screen_capture.read()
    #         if not success:
    #             break
    #         ret, buffer = cv2.imencode('.png', frame)
    #         if not ret:
    #             break
    #         frame_bytes = buffer.tobytes()
    #         yield (b'--frame\r\n'
    #                b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')

    # def generate_frames(self):
    #     cap = cv2.VideoCapture(0)  # Adjust the camera index or video file as needed
    #
    #     while True:
    #         success, frame = cap.read()
    #         if not success:
    #             break
    #         else:
    #             ret, buffer = cv2.imencode('.jpg', frame)
    #             frame = buffer.tobytes()
    #             yield (b'--frame\r\n'
    #                    b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

    # def __init__(self):
    #
    #     self.app = Flask(__name__)
    #     self.app.secret_key = "Test"
    #     self.sio = socketio.Server(cors_allowed_origins="*")
    #     self.app.wsgi_app = socketio.WSGIApp(self.sio, self.app.wsgi_app)
    #
    #     @self.app.route("/", methods=["GET"])
    #     def send_screenshot():
    #         host = StreamingServer('127.0.0.1', 80)
    #         th = threading.Thread(target=host.start_server())
    #
    #         while input("") != 'stop':
    #             continue
    #
    #         host.stop_server()
    #         # # Capture the screenshot
    #         # screenshot = pyautogui.screenshot()
    #         #
    #         # # Convert the image to bytes
    #         # img_bytes = io.BytesIO()
    #         # screenshot.save(img_bytes, format='PNG')
    #         # img_bytes = img_bytes.getvalue()
    #         #
    #         # # Return the image as a response with the appropriate content type
    #         # return Response(img_bytes, content_type='image/png')
    #
    #     # @self.sio.on('connect', namespace='/screen')
    #     # def handle_connect(sid, environ):
    #     #     # Handle the connection from the mobile device
    #     #     pass
    #
    # def capture_and_send_frame(self):
    #     while True:
    #         screenshot = pyautogui.screenshot()
    #         img_data = base64.b64encode(screenshot.tobytes()).decode('utf-8')
    #         self.sio.emit('frame', {'image': img_data})
    #
    # def share(self):
    #     sender = ScreenShareClient('127.0.0.1', 80)
    #     sender.start_stream()
    #
    # # # Capture and stream frames
    # # def capture_and_send_frame(self):
    # #     while True:
    # #         screenshot = pyautogui.screenshot()
    # #         img_data = base64.b64encode(screenshot.tobytes()).decode('utf-8')
    # #         self.sio.emit('frame', {'image': img_data}, namespace='/screen')
    # #
    # # def display_streamed_frames(self):
    # #     while True:
    # #         try:
    # #             response = requests.get(f"http://127.0.0.1:80/frame", stream=True)
    # #             if response.status_code == 200:
    # #                 img_bytes = BytesIO(response.content)
    # #                 frame = cv2.imdecode(np.frombuffer(img_bytes.read(), np.uint8), cv2.IMREAD_COLOR)
    # #                 cv2.imshow('Streamed Frame', frame)
    # #                 if cv2.waitKey(1) & 0xFF == ord('q'):
    # #                     break
    # #         except Exception as e:
    # #             print(f"Error: {e}")
    # #
    # #     cv2.destroyAllWindows()
    #
    # def getApp(self):
    #     return self.app

# class ScreenServer(Server):
#     def __init__(self):
#         super().__init__()
#         self.camera_client = CameraClient('127.0.0.1', 80)
#         self.camera_client.start_server()
#
#     def generate_frames(self):
#         while True:
#             frame = self.camera_client.get_frame()
#             yield (b'--frame\r\n'
#                    b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

# def generate_screenshots(self):
    #     while True:
    #         screenshot = pyautogui.screenshot()
    #         img_bytes = io.BytesIO()
    #         screenshot.save(img_bytes, format='PNG')
    #         img_bytes = img_bytes.getvalue()
    #         yield (b'--frame\r\n'
    #                b'Content-Type: image/png\r\n\r\n' + img_bytes + b'\r\n')

