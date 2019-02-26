#!/usr/bin/env python

import argparse
from pyrfc import Connection

def get_profile_info(connection, fq_profile_name, profile_type):
    result = connection.call("PFL_READ_PROFILE_FROM_FILE", FULLY_QUALIFIED_PROFILENAME=fq_profile_name, PROFILE_TYPE="I")
    return result['DTAB']

def update_params(profiles, params, source_sid, ascs_hostname):
    for param in params.keys():
        profile = get_profile(profiles, param)

        if profile != None:
            profile["PVALUE"] = params[param]
        else:
            new_profile = {
                "VERSNR": "000000",
                "PSTATE": "",
                "PFNAME": "{0}_ASCS00_{1}".format(source_sid, ascs_hostname),
                "DENAME": "", 
                "COMNR": "9990", 
                "PVALUE": params[param], 
                "PARNR": get_next_parnr(profiles), 
                "MODPROG": "", 
                "CHKPRG": "", 
                "CREFPF": "", 
                "PARNAME": param
            }

            profiles.append(new_profile)  

# Gets the highest `PARNR` value and increments it by one
def get_next_parnr(profiles):
    max_parnr = 0
    for profile in profiles:
        if int(profile["PARNR"]) > max_parnr:
            max_parnr = int(profile["PARNR"])

    next_parnr = max_parnr + 1
    return format(next_parnr, "04")

def get_profile(profiles, parameter):
    for profile in profiles:
        if parameter == profile["PARNAME"]:
            return profile

    return None

# Retrieves full OS profile path (case-sensitive)
def get_os_profile_path(conn):
    return "This"

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="ASCS Parameters")
    parser.add_argument("-a", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-s", "--source-sid", type=str, required=True, help="SID for source SAP profiles")
    parser.add_argument("-c", "--ascs-hostname", type=str, required=True, help="ASCS hostname (short)")
    parser.add_argument("-f", "--profile-parameters-file", type=str, required=True, help="File containing profile names and values which require insertion/modification (pipe-separated values)")
    args = parser.parse_args()

    # Load profile parameters
    params = {}
    with open(args.profile_parameters_file) as f:
        for line in f.read().splitlines():
            l = line.split('|')
            params[l[0]] = l[1]

    # Set up connection to PAS
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_password)

    fqpn = "\\\\{0}\\SAPMNT\\{1}\\SYS\\PROFILE\\{2}_ASCS00_{3}".format(args.ascs_hostname.upper(), args.source_sid.upper(), args.source_sid.upper(), args.ascs_hostname.upper())

    profile = get_os_profile_path(conn)
    
    profiles = get_profile_info(conn, fqpn, 'I')

    update_params(profiles, params, args.source_sid, args.ascs_hostname)

    print(conn.call("PFL_WRITE_PROFILE_TO_FILE", FULLY_QUALIFIED_PROFILENAME="\\\\azsaw0625\sapmnt\IA3\SYS\profile\IA3_ASCS00_AZSAW0625", PROFILE_TYPE="I", DTAB=profiles, PROFILE_NAME="IA3_ASCS00_AZSAW0625"))

main()