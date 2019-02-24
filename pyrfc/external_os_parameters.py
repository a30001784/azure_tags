#!/usr/bin/env python

import argparse
from pyrfc import Connection

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="Re-assign SAP external OS parameters")
    parser.add_argument("-h", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-s", "--source-ascs-hostname", type=str, required=True, help="Source ASCS hostname")
    parser.add_argument("-t", "--target-ascs-hostname", type=str, required=True, help="Target ASCS hostname")
    args = parser.parse_args()

    # Set up connection to PAS
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_hostname)

    result = conn.call("SXPG_COMMAND_LIST_GET", COMMANDNAME="Z*")
    command_list = result["COMMAND_LIST"]

    for command in command_list:
        opcmd = command["OPCOMMAND"]
        parameters = command["PARAMETERS"].encode("utf-8")

        if args.source_ascs_hostname in opcmd:
            opcmd = opcmd.replace(args.source_ascs_hostname, args.target_ascs_hostname)

        if args.source_ascs_hostname in parameters:
            parameters = parameters.replace(args.source_ascs_hostname, args.target_ascs_hostname).decode("utf-8")

        data = {
            "NAME": command["NAME"],
            "OPCOMMAND": opcmd,
            "OPSYSTEM": command["OPSYSTEM"], 
            "PARAMETERS": parameters
        }

        conn.call("Z_BA_SXPG_COMMAND_MODIFY", COMMAND=data)

main()