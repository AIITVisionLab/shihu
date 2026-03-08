package com.aurora.iotonenet.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 首页 -> 介绍页
        registry.addViewController("/").setViewName("forward:/preview.html");

        // 可选：给控制台单独保留地址
        registry.addViewController("/dashboard").setViewName("forward:/index.html");
    }
}