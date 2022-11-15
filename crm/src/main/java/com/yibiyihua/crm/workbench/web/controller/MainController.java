package com.yibiyihua.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/26 8:16
 * @description：main控制器
 * @modified By：
 * @version: 1.0
 */
@RequestMapping("/workbench/main")
@Controller
public class MainController {

    /**
     * 跳转”工作台“默认页面
     * @return
     */
    @RequestMapping("/index.do")
    public String index() {
        return "workbench/main/index";
    }
}
