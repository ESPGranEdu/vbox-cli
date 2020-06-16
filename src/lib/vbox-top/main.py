#!/usr/bin/env python
import json
import os
import subprocess
from glob import glob
from time import sleep
import xml.etree.ElementTree as ET

import psutil
import requests
from flask import Flask, jsonify, render_template, request

# Get info about running VMs


def get_vm_specs(vm_name: str) -> dict:
    """
    Return a dict containing the extra specifications of the specified VM
    """
    vbox_files = os.path.realpath(os.environ["HOME"] + "/VirtualBox VMs/**/")

    for vbox_file in glob(vbox_files, recursive=True):
        if not vbox_file.endswith(f"{vm_name}.vbox"):
            continue

        # Parse VM's .vbox file
        xml_tree = ET.parse(vbox_file).getroot()
        hardware = xml_tree[0].findall("{http://www.virtualbox.org/}Hardware")

        # Get Specs
        if len(hardware[0][0].keys()) == 0:
            cpu_core_count = 1

        cpu_core_count = hardware[0][0].attrib["count"]
        vm_os_type = xml_tree[0].attrib["OSType"]
        ram_size = hardware[0][1].attrib["RAMSize"]

        # Stop running the loop
        break

    # Return dict containing VMs specs
    return {
        "os_type": vm_os_type,
        "cpu_core_count": int(cpu_core_count),
        "ram_size": int(ram_size)
    }


def get_vm_pid():
    """ Return a collector with the PIDs of the currently running VMs """

    try:
        pids = map(int, subprocess.check_output(
            ["pidof", "VBoxHeadless", "VirtualBoxVM"]).split())

    except (subprocess.CalledProcessError):
        return {}

    return pids


app = Flask(__name__)


@app.route('/api', methods=["GET"])
def vm_info():
    """
    Return a JSON file containing all the information of the currently
    running VMs on the host
    """

    vms_info = {}
    for pid in get_vm_pid():
        try:
            proc = psutil.Process(pid)
            vm_name = proc.cmdline()[2]
            vm_specs = get_vm_specs(vm_name)  # Extra specs

            load_percentage = round(
                proc.cpu_percent(.500) / vm_specs["cpu_core_count"], 0)

            # Append collected info
            vms_info[vm_name] = {
                "cpu_cores": vm_specs["cpu_core_count"],
                "ram_size": vm_specs["ram_size"],
                "load_percentage": load_percentage,
                "os_type": vm_specs["os_type"]
            }
        except Exception:
            continue

    # Send JSON
    return jsonify(vms_info)


@app.after_request
def add_headers(r):
    """
    Add headers to both force latest IE rendering engine or Chrome Frame,
    and also to cache the rendered page for 10 minutes.
    """
    r.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    r.headers["Pragma"] = "no-cache"
    r.headers["Expires"] = "0"
    r.headers['Cache-Control'] = 'public, max-age=0'
    return r

# Return VMs info as JSON
@app.route("/")
def index():
    return render_template("index.html")


# Run server
if __name__ == "__main__":
    app.run(debug=True)
