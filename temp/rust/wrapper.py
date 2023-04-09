#!/usr/bin/env python

import subprocess
import os
import sys
import signal
import json
import websocket
import time
import logging
import traceback


startupCmd = ""
try:
    with open("latest.log", "w") as f:
        f.write("")
except Exception as e:
    print("Exception occurred while writing to file:", e)


args = sys.argv[1:]
startupCmd = " ".join(args)

if len(startupCmd) < 1:
    print("Error: Please specify a startup command.")
    sys.exit()

seenPercentage = {}

print("Starting Rust...")

exited = False
gameProcess = subprocess.Popen(startupCmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def filter(data):
    str = data.decode().strip()
    if str.startswith("Loading Prefab Bundle "):
        percentage = str[len("Loading Prefab Bundle "):]
        if percentage in seenPercentage:
            return
        seenPercentage[percentage] = True
    print(str.strip('"'), end="")


while True:
    data = gameProcess.stdout.readline()
    if not data:
        break
    filter(data)

while True:
    data = gameProcess.stderr.readline()
    if not data:
        break
    filter(data)

code = gameProcess.wait()
exited = True

if code:
    print("Main game process exited with code " + str(code))
    # sys.exit(code)

def initialListener(data):
    command = data.decode().strip()
    if command == "quit":
        gameProcess.kill()
    else:
        print('Unable to run "' + command + '" due to RCON not being connected yet.')



def exitListener(signal, frame):
    if exited:
        return
    print("Received request to stop the process, stopping the game...")
    gameProcess.kill()
    sys.exit(0)

signal.signal(signal.SIGTERM, exitListener)

while True:
    try:
        data = input()
        initialListener(data.encode())
    except EOFError:
        break



def create_packet(command):
    packet = {
        "Identifier": -1,
        "Message": command,
        "Name": "WebRcon"
    }
    return json.dumps(packet)

def on_message(ws, message):
    try:
        json_message = json.loads(message)
        if json_message is not None and 'Message' in json_message and len(json_message['Message']) > 0:
            print(json_message['Message'])
            with open("latest.log", "a") as log_file:
                log_file.write("\n" + json_message['Message'])
    except Exception as e:
        print("Error: Invalid JSON received.")
        traceback.print_exc()

def on_error(ws, error):
    global waiting
    waiting = True
    print("Waiting for RCON to come up...")
    time.sleep(5)
    poll()

def on_close(ws):
    global waiting, exited
    if not waiting:
        print("Connection to server closed.")
        exited = True
        sys.exit()

def on_open(ws):
    global waiting
    print("Connected to RCON. Generating the map now. Please wait until the server status switches to \"Running\".")
    waiting = False
    # Hack to fix broken console output
    ws.send(create_packet('status'))

    # Set the stdin input listener to send RCON commands
    sys.stdin = os.fdopen(sys.stdin.fileno())
    sys.stdin.flush()
    def on_input(text):
        ws.send(create_packet(text.strip()))
    sys.stdin = os.fdopen(sys.stdin.fileno(), 'r', 0)
    sys.stdin.on_input = on_input

def poll():
    try:
        global waiting
        if waiting:
            server_hostname = os.getenv('RCON_IP', 'localhost')
            server_port = os.getenv('RCON_PORT')
            server_password = os.getenv('RCON_PASS')
            ws = websocket.WebSocketApp("ws://{0}:{1}/{2}".format(server_hostname, server_port, server_password),
                                        on_message=on_message,
                                        on_error=on_error,
                                        on_close=on_close)
            ws.on_open = on_open
            ws.run_forever()
    except KeyboardInterrupt:
        global exited
        exited = True
        print("Received request to stop the process, stopping the game...")
        os.killpg(os.getpgid(gameProcess.pid), signal.SIGTERM)
        sys.exit()
    except Exception as e:
        traceback.print_exc()
        time.sleep(5)
        poll()

# Start the websocket connection
waiting = True
exited = False
poll()
