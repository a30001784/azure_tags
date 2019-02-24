#!/usr/bin/env python

import argparse, json, re
from sets import Set
from pyrfc import Connection

def get_profile_info(connection, source_sid):
    fields = [{ "FIELDNAME": "PFLINSNAME" }]
    options = [{ 'TEXT': "SYSNAME = '" + source_sid + "' AND STATUS <> '3'" }]
    result = connection.call('/BODS/RFC_READ_TABLE', QUERY_TABLE='TPFID', DELIMITER=',', OPTIONS=options, FIELDS=fields)

    profiles = Set()
    for p in result['DATA']:
        profiles.add(p['WA'])

    profile_info = []
    for profile in profiles:
        data = {
            "pfname": profile
        }

        profile_info.append(data)
    
    return profile_info

def get_defaults(connection, source_sid):
    defaults = []

    result = connection.call('PFL_GET_PROF_LIST')

    # example matching patterns: ( azsaw0607_IA3_10 , GLBWI1331_IP1_10 )
    pattern = "([A-Za-z]{5})([0-9]{4})_" + source_sid + "_([0-9]{2})"
    prog = re.compile(pattern)
    for profile in result['HEADER_TAB']:
        if profile['PFNAME'] == "DEFAULT" and prog.match(profile['SERVERNAME']):
            data = {
                "pfname": profile['PFNAME'],
                "version": profile['VERSNR']
            }
            defaults.append(data)

    return defaults

# Gets the latest (highest) profile version based on the VERSNR field
def get_latest_version(profiles):
    latest = 0
    lv = {}
    
    for profile in profiles:
        if int(profile['version']) > latest:
            latest = int(profile['version'])
            lv = profile
    return lv

# Gets the PAS server (determined by the app server profile which has the lowest numerical hostname)
def get_primary_app_server(profiles):
    pas_hostname = "ZZZZZ9999"

    # get lowest hostname and assign it to the PAS
    for profile in profiles:
        if profile == "DEFAULT":
            continue
        
        hostname = profile.split('_')[-1]
        if hostname < pas_hostname:
            pas_hostname = hostname

    return pas_hostname

def read_profiles_from_db(connection, profiles):
    exclusions = ()
    source_params = {}

    with open("./profile_exclusions.txt") as f:
        exclusions = f.read().splitlines()

    for profile in profiles:

        if profile['pfname'] == "DEFAULT":
            result = connection.call('PFL_READ_PROFILE_FROM_DB', PROFILE_NAME=profile['pfname'], PROFILE_VERSION=profile['version'])
        else:
            result = connection.call('PFL_READ_PROFILE_FROM_DB', PROFILE_NAME=profile['pfname'])
        
        dtab = result['DTAB']

        for row in dtab:
            pfname = row['PFNAME']
            parname = row['PARNAME']
            pvalue = row['PVALUE']

            if parname not in exclusions:
                # Skip blank parameters and params matching the pattern DIR_*, SETENV* or Start_Program*
                if "" in (parname, pvalue) or parname.startswith(("DIR_", "SETENV", "Start_Program")):
                    continue

                nv = { 
                    "NAME": parname,
                    "VALUE": pvalue
                }

                # Create profile name/value pair if it doesn't exist
                if pfname not in source_params:
                    source_params[pfname] = []

                source_params[pfname].append(nv)

    return source_params

def spfl_api_del_and_create(connection):
    # Clean up old profiles
    connection.call('SPFL_API_DEL_AND_CREATE', FUNCTION='1')

    # Return list of target profiles
    return connection.call('SPFL_API_DEL_AND_CREATE', FUNCTION='2')

def map_profiles(source, target, target_sid):
    mapping_table = []
    source_profiles, source_instances, target_profiles, target_instances = ['DEFAULT'], ['DEFAULT'], ['DEFAULT'], ['DEFAULT']

    # Source profiles and instances
    for s in source.keys():
        if s == "DEFAULT":
            continue

        source_profiles.append(s)
            
        # Construct instance name from profile name: e.g. IP1_D10_GLBWI1370 -> GLBWI1370_IP1_10
        chunks = s.split('_')
        instance_name = chunks[2] + "_" + chunks[0] + "_" + chunks[1][-2:]
        source_instances.append(instance_name)

    # Target profiles and instances
    for t in target['PROFLIST']:
        pfname = t['PFNAME']
        if pfname.startswith(target_sid):
            target_profiles.append(pfname)
            target_instances.append(t['SERVERNAME'])

    # Sort source and target lists
    source_profiles.sort(profile_sort)
    source_instances.sort()
    target_profiles.sort(profile_sort)
    target_instances.sort()

    # Create mapping table
    for index in range(len(target_profiles)):
        data = {
            "source_profile_name": source_profiles[index],
            "source_instance_name": source_instances[index],
            "target_profile_name": target_profiles[index],
            "target_instance_name": target_instances[index]
        }
        mapping_table.append(data)

    return mapping_table

# Stupid complex sorting algorithm
def profile_sort(a, b):
    chunks_a = a.split('_')
    chunks_b = b.split('_')

    # Handle anomalous profiles
    if len(chunks_a) == 1 or len(chunks_b) == 1:
        if a < b:
            return -1
        elif a > b:
            return 1
        else:
            return 0

    # Profile names are the same
    if a == b:
        return 0

    # Sort by hostname first
    if chunks_a[2] > chunks_b[2]:
        return 1
    elif chunks_a[2] < chunks_b[2]:
        return -1
    else:
        # Then sort by instance number
        if chunks_a[1][-2:] > chunks_b[1][-2:]:
            return 1
        elif chunks_a[1][-2:] < chunks_b[1][-2:]:
            return -1
        else:
            return 0

def update_target_profiles(connection, mapping_table, source):
    for profile in source.keys():
        dtab = source[profile]
        row = get_mapping_table_row(mapping_table, "source_profile_name", profile)

        if row == None:
            print "No entry found in mapping table for source profile name: " + profile
            return

        iv_file_name = row['target_profile_name']

        if profile == "DEFAULT":
            # Static entries for Default profile
            saptranshost = {
                "NAME": "SAPTRANSHOST",
                "VALUE": "azsaw0011.agl.int"
            }
            server_port = {
                "NAME": "icm/server_port_0",
                "VALUE": "PROT=HTTP,PORT=80$$,TIMEOUT=90,PROCTIMEOUT=600"    
            }
            dtab.extend([saptranshost, server_port])

            # Update PHYS_MEMSIZE to 30%
            exists = False
            for d in dtab: 
                if d["NAME"] == "PHYS_MEMSIZE":
                    d["VALUE"] = "30%"
                    exists = True

            if exists == False:
                phys_memsize = {
                    "NAME": "PHYS_MEMSIZE",
                    "VALUE": "30%"
                }
                dtab.append(phys_memsize)

        connection.call('SPFL_SET_MULTI_IN_FILE_AND_DB', IT_MODIFY_PARAMETER=dtab, IV_FILE_NAME=iv_file_name)

def get_mapping_table_row(mapping_table, key, val):
    for row in mapping_table: 
        if row[key] == val:
            return row

    return None

def export_mapping_table(mapping_table, outfile):
    with open(outfile, "w") as f:
        json.dump(mapping_table, f)

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="SAP profiles importer")
    parser.add_argument("-h", "--as-hostname", type=str, required=True, help="Application server hostname")
    parser.add_argument("-u", "--as-username", type=str, required=True, help="Application server username")
    parser.add_argument("-p", "--as-password", type=str, required=True, help="Application server password")
    parser.add_argument("-s", "--source-sid", type=str, required=True, help="SID for source SAP profiles")
    parser.add_argument("-t", "--target-sid", type=str, required=True, help="SID for target SAP profiles")
    args = parser.parse_args()

    # Set up connection to PAS
    conn = Connection(ashost=args.as_hostname, sysnr='10', client='100', user=args.as_username, passwd=args.as_hostname)

    # Construct list of unique profiles
    profiles = get_profile_info(conn, args.source_sid)
    defaults = get_defaults(conn, args.source_sid)
    
    # There are multiple versions of the DEFAULT profile, so only add the latest
    latest_default_version = get_latest_version(defaults)
    profiles.append(latest_default_version)

    # Get source/target profiles and instances
    source = read_profiles_from_db(conn, profiles)
    target = spfl_api_del_and_create(conn)

    # Construct mapping table for source/target profiles and instances
    mapping_table = map_profiles(source, target, args.target_sid)

    # Export mapping table to json file for later use
    export_mapping_table(mapping_table, "./mapping_table.json")

    # Update SAP profiles in the target system
    update_target_profiles(conn, mapping_table, source)

main()