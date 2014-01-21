#!/usr/bin/python

import os, getpass, hashlib, base64, glob, subprocess

print "Please unmount any open vault images."

directory = "~/Library/Application\ Support/.fconfig/"

if not os.path.exists(directory):
    os.makedirs(directory)

password = getpass.getpass("Password for vault: ")
confirmPassword = getpass.getpass("Confirm password: ")

if password != confirmPassword:
	print "Passwords do not match."
	exit(-1)

for i in range(1, 1001):
	text = (password + `i`).encode('latin1')
	digest = hashlib.sha512(text).digest()
	password = base64.standard_b64encode(digest).replace('=', '')

files = glob.glob(os.getenv("HOME") + "/Library/Application Support/.fconfig/*.sparseimage");

for f in files:
	args = ["hdiutil", "imageinfo", "-format", "-stdinpass", f];
	p = subprocess.Popen(args, shell=False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	p.communicate(password)

	if(p.returncode == 0):
		print "A disk already exists with the given password. You must choose a different password"
		exit(-1)

i = 1
newImg = os.getenv("HOME") + "/Library/Application Support/.fconfig/Vault" + `i` + ".sparseimage"
while os.path.isfile(newImg):
	i += 1
	newImg = os.getenv("HOME") + "/Library/Application Support/.fconfig/Vault" + `i` + ".sparseimage"

newImg = newImg.replace('.sparseimage', '')

args = ['hdiutil', 'create', '-verbose', '-stdinpass', '-encryption', 'AES-256', '-type', 'SPARSE', '-fs', 'Journaled HFS+', '-volname', 'Vault', newImg]
p = subprocess.Popen(args, shell=False, stdin=subprocess.PIPE)
try:
	p.communicate(password);
except:
	p.kill()

if p.returncode == 0:
	print "You may now use your new vault"
else:
	print "An error occured"