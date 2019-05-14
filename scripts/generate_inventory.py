#!/usr/bin/env python3

import argparse, os, re, subprocess

def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Generate Ansible inventory file")
    parser.add_argument("-r", "--roles", nargs="+", type=str, required=True, help="List of roles", default=[])
    parser.add_argument("-s", "--sub-roles", nargs="+", type=str, required=True, help="List of sub roles", default=[])
    parser.add_argument("-i", "--inv-dir", type=str, required=True, help="Relative path to output inventory file. Must be a directory.")
    parser.add_argument("-t", "--tf-path", type=str, required=True, help="Relative path from working directory to Terraform directory.")
    args = parser.parse_args()

    # Check for valid TF directory
    if not os.path.exists(args.tf_path):
        print("Specified path not valid Terraform directory: {}".format(args.tf_path))
        exit(1)

    # Check for valid directory for inventory file
    if not os.path.isdir(args.inv_dir):
        print("Invalid directory for Ansible inventory file: {}".format(args.inv_dir))
        exit(2)

    # Get absolute file path for inventory file
    inv_dir = os.path.abspath(args.inv_dir)

    # Change to Terraform working directory
    os.chdir(args.tf_path)

    generate_file(args.roles, args.sub_roles, inv_dir)

def generate_file(roles, sub_roles, inv_dir):
    f = open("{}/inventory.txt".format(inv_dir), "w+")

    for role in roles:
        children = []

        for sub_role in sub_roles:
            full_role = "{}-{}".format(role, sub_role)
            f.write("[{}]\n".format(full_role))
            children.append(full_role)

            tf_output = subprocess.run(["terraform", "output", "ip_addresses_{}".format(full_role)], stdout=subprocess.PIPE)

            # Strip commas and newline chars and store in array
            ip_addresses = re.sub(',','', tf_output.stdout.decode("utf-8")).splitlines()

            for ip in ip_addresses:
                variables=""

                if sub_role == "data":
                    disks="NUM_POOLED_DISKS_DATA_{}".format(role.upper())
                    backup="HAS_BACKUP_DISK_{}".format(role.upper())
                    variables="num_pooled_disks={} has_backup_disk={}".format(os.environ.get(disks), os.environ.get(backup))

                f.write("{} {}\n".format(ip, variables))

            f.write("\n")

        # Parent role
        f.write("[{}:children]\n".format(role))

        # Children
        for child in children:
            f.write("{}\n".format(child))

        f.write("\n")

    for sub_role in sub_roles:
        f.write("[{}:children]\n".format(sub_role))

        for role in roles:
            f.write("{}-{}\n".format(role, sub_role))

        f.write("\n")

    f.close()

main()