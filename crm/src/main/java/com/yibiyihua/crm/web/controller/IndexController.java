package com.yibiyihua.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/23 14:10
 * @description：默认控制器
 * @modified By：
 * @version: 1.0
 */

@Controller
public class IndexController {

    /**
     * 跳转默认页
     * @return
     */
    @RequestMapping("/")
    public String index() {
        return "index";
    }
}
