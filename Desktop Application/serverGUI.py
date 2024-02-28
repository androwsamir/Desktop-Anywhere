import random
import pyperclip
from PyQt5 import QtCore, QtGui, QtWidgets
import Gui
import sys
from Server import Server
import threading
import multiprocessing
from multiprocessing import Event

def copy_to_clipboard(text):
    pyperclip.copy(text)

def generatePassword():
    j = random.randint(0, 56)
    # Define the character set you want to use
    charset = "0123456789abcdefghijklmnopqrstuvwxyz@#$%!?*()_-+=&^{}[]<>"

    # Initialize a list to store the generated strings
    generated_password = ''

    # Iterate through combinations of characters
    for i in range(8):
        generated_password += charset[j]
        j = random.randint(0, 56)

    return generated_password

def relaod_credentials(window, publicIP):

    # set ID here
    window.main_p2_label_id.setText(publicIP)

    # set Password here
    window.main_p2_label_password.setText(generatePassword())

def runGUI(publicIP, password):
    app = QtWidgets.QApplication(sys.argv)
    window = Gui.Ui_MainWindow()
    window.setIPAndPassword(publicIP, password)

    # coonect to copy function
    window.main_p2_btn_copy_id.clicked.connect(lambda: copy_to_clipboard(window.main_p2_label_id.text()))
    window.main_p2_btn_copy_password.clicked.connect(
        lambda: copy_to_clipboard(window.main_p2_label_password.text()))

    # coonect to reload function
    window.main_p2_btn_reload.clicked.connect(lambda: relaod_credentials(window, publicIP))

    window.show()
    exit(app.exec_())
    
if __name__ == '__main__':
    server = Server()

    publicIP = server.get_public_ip()
    password = generatePassword()
    # runGUI(publicIP, password)

    app = server.run(password)

    gui_process = multiprocessing.Process(target=runGUI, args=[publicIP, password])
    gui_process.start()
    app.run(host='0.0.0.0', port=8888, debug=True, use_reloader=False)
    gui_process.join()

    # server_process.start()

    # server_process.join()
