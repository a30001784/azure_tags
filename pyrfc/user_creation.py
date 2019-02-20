#!/usr/bin/env python

import argparse, csv, os
from itertools import islice
from pyrfc import Connection

def map_users(csv_file, password):
    users = {}

    with open(csv_file, 'rb') as f:
        reader = csv.reader(f)

        rownum = 0

        for row in reader:
            if rownum > 0:
                user_name = row[0]
                role = row[4]
                profile = row[5]

                user = {}

                # User does not exist in dictionary. Create it
                if user_name not in users.keys():

                    users[user_name] = {
                        "full_name": row[1],
                        "password": password,
                        "user_type": row[3],
                        "roles": [],
                        "profiles": []            
                    }

                # User exists. Add their roles and profiles
                # else:
                user = users[user_name]
                if role != "":
                    user["roles"].append(role)
                
                if profile != "":
                    user["profiles"].append(profile)

            rownum += 1

    return users

def delete_users(conn, users):
    for user in users:
        # If user exists in system, delete it
        result = conn.call("BAPI_USER_EXISTENCE_CHECK", USERNAME=user)
        if result["RETURN"]["MESSAGE"] == "User {0} exists".format(user):
            print("Deleting user: {0}".format(user))
            result = conn.call("BAPI_USER_DELETE", USERNAME=user)

def create_users(conn, users):
    for user in users:
        logondata = { "USTYP": users[user]["user_type"] }
        password = { "BAPIPWD": users[user]["password"] }
        result = conn.call("BAPI_USER_CREATE1", USERNAME=user, LOGONDATA=logondata, ADDRESS={}, PASSWORD=password)
        print(result)

    print("\n")

def assign_profiles(conn, users):
    for user in users:        
        profiles = []
        for profile in users[user]["profiles"]:
            profiles.append({
                "BAPIPROF": profile
            })

        if len(users[user]["profiles"]) > 0:
            result = conn.call("BAPI_USER_PROFILES_ASSIGN", USERNAME=user, PROFILES=profiles)
            print(result)

    print("\n")

def assign_groups(conn, users):
    for user in users:
        roles = []
        for role in users[user]["roles"]:
            roles.append({
                "AGR_NAME": role
            })
        
        if (len(users[user]["roles"]) > 0):
            result = conn.call("BAPI_USER_ACTGROUPS_ASSIGN", USERNAME=user, ACTIVITYGROUPS=roles)
            print(result)

def main():
    # Parse command line args
    parser = argparse.ArgumentParser(description="SAP users creation")
    parser.add_argument("-f", "--csv-file", type=str, required=True, help="CSV file containing user and profile details")
    parser.add_argument("-p", "--password", type=str, required=True, help="Initial password for new users")
    args = parser.parse_args()

    # Set up connection to PAS
    conn = Connection(ashost='azsaw0607.agl.int', sysnr='10', client='100', user='DDIC', passwd=os.environ['SAP_RFC_PASSWORD'])

    users = map_users(args.csv_file, args.password)

    delete_users(conn, users)

    create_users(conn, users)

    assign_profiles(conn, users)

    assign_groups(conn, users)

main()

