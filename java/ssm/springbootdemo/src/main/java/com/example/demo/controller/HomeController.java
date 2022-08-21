package com.example.demo.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/home")
public class HomeController {

    @RequestMapping(path = "/index",method = RequestMethod.GET)
    @ResponseBody
    public String hello() {
        return "hello word!";
    }
}
