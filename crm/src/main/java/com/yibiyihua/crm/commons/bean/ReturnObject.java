package com.yibiyihua.crm.commons.bean;

/**
 * @author ：yibiyihua
 * @date ：Created in 2022/9/24 14:06
 * @description：返回前端数据
 * @modified By：
 * @version: 1.0
 */
public class ReturnObject {
    private String code;
    private String message;

    private Object obj;

    public ReturnObject() {
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Object getObj() {
        return obj;
    }

    public void setObj(Object obj) {
        this.obj = obj;
    }
}
