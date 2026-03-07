package com.aurora.iotonenet.application.service;

import com.aurora.iotonenet.api.dto.LoginRequest;
import com.aurora.iotonenet.api.dto.LoginResponse;
import jakarta.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class LoginApplicationService {

    private static final Logger logger = LoggerFactory.getLogger(LoginApplicationService.class);
    private static final String SESSION_USER_KEY = "logged_in_user";

    @Value("${app.login.username}")
    private String configUsername;

    @Value("${app.login.password}")
    private String configPassword;

    public LoginResponse login(LoginRequest request, HttpSession session) {
        String username = request.getUsername();
        String password = request.getPassword();
        logger.info("登录尝试: username={}", username);

        if (configUsername.equals(username) && configPassword.equals(password)) {
            session.setAttribute(SESSION_USER_KEY, username);
            logger.info("用户登录成功: {}", username);
            return new LoginResponse(true, "登录成功");
        }

        logger.warn("登录失败: username={}", username);
        return new LoginResponse(false, "用户名或密码错误");
    }

    public Map<String, Object> checkLogin(HttpSession session) {
        Map<String, Object> response = new HashMap<>();
        Object user = session.getAttribute(SESSION_USER_KEY);
        if (user != null) {
            response.put("loggedIn", true);
            response.put("username", user);
        } else {
            response.put("loggedIn", false);
        }
        return response;
    }

    public LoginResponse logout(HttpSession session) {
        Object user = session.getAttribute(SESSION_USER_KEY);
        if (user != null) {
            logger.info("用户登出: {}", user);
            session.invalidate();
        }
        return new LoginResponse(true, "已登出");
    }
}
