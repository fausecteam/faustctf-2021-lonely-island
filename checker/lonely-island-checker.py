#!/usr/bin/env python3

from ctf_gameserver import checkerlib

import utils

import logging
import subprocess
import secrets
import string
import os

class TemplateChecker(checkerlib.BaseChecker):

    RETURN_CODES = {
        0: checkerlib.CheckResult.OK,
        1: checkerlib.CheckResult.DOWN,
        2: checkerlib.CheckResult.FAULTY,
        3: checkerlib.CheckResult.FLAG_NOT_FOUND,
    }
    
    def run(self, path, **kwargs):
        logging.info(f"Starting godot on scene `{path}` with `{kwargs}`")
        process = subprocess.run(["../Godot_v3.2.3-stable_linux_server.64", path], cwd=os.path.join(os.path.dirname(__file__), './client/'), env={**kwargs, 'HOST': self.ip, 'PORT': '4321'})
        return_code_string = self.RETURN_CODES[process.returncode] if process.returncode in self.RETURN_CODES else 'N/A'
        logging.info(f"Subprocess returned { process.returncode } ({ return_code_string })")
        return self.RETURN_CODES[process.returncode]

    def run_async(self, path, **kwargs):
        logging.info(f"Starting godot on scene `{path}` with `{kwargs}`")
        process = subprocess.Popen(["../Godot_v3.2.3-stable_linux_server.64", path], cwd=os.path.join(os.path.dirname(__file__), './client/'), env={**kwargs, 'HOST': self.ip, 'PORT': '4321'})
        return process

    def randstring(self):
        return ''.join([secrets.choice(string.ascii_letters + string.digits + string.punctuation) for x in range(secrets.randbelow(16) + 32)])
    
    def place_flag(self, tick):
        flag = checkerlib.get_flag(tick)
        user = self.randstring()
        password = self.randstring()
        user2 = self.randstring()
        password2 = self.randstring()
        logging.info(f"Trying to place flag {flag} for tick {tick} with user `{user}` : `{password}`")
        checkerlib.store_state(str(tick), {'user': user, 'password': password, 'read_user': user2, 'read_password': password2})
        return self.run("place_flag.tscn", FLAG=flag, USER=user, PASSWORD=password, READ_USER=user2, READ_PASSWORD=password2, READ_BIO=utils.generate_message())

    def check_service(self):
        logging.info("Checking Service")
        user1, pw1 = self.randstring(), self.randstring()
        user2, pw2 = self.randstring(), self.randstring()
        proc1 = self.run_async("check_service.tscn", USER1=user1, PASSWORD1=pw1, BIO=utils.generate_message(), USER2=user2)
        proc2 = self.run_async("check_service.tscn", USER1=user2, PASSWORD1=pw2, BIO=utils.generate_message(), USER2=user1)
        returncodes = [ p.wait() for p in (proc1, proc2) ]
        for i, returncode in enumerate(returncodes):
            return_code_string = self.RETURN_CODES[returncode] if returncode in self.RETURN_CODES else 'N/A'
            logging.info(f"Subprocess #{i} returned { returncode } ({ return_code_string })")
        return self.RETURN_CODES[returncodes[0] or returncodes[1]]

    def check_flag(self, tick):
        flag = checkerlib.get_flag(tick)
        state = checkerlib.load_state(str(tick))
        user, read_user, read_password = state['user'], state['read_user'], state['read_password']
        logging.info(f"Trying to retrieve flag {flag} (from user `{user}`) for tick {tick} with user `{read_user}` : `{read_password}`")
        return self.run("check_flag.tscn", FLAG=flag, USER = user, READ_USER=read_user, READ_PASSWORD=read_password)


if __name__ == '__main__':
    checkerlib.run_check(TemplateChecker)
