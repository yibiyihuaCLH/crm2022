package com.yibiyihua.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/24 15:42
 * @description：工作台默认控制器
 * @modified By：
 * @version: 1.0
 */

@Controller
public class WorkBenchIndexController {

    /**
     * 跳转工作台默认界面
     * @return
     */
    @RequestMapping("/workbench/index.do")
    public String index() {
        return "workbench/index";
    }
}
