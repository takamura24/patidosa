package com.example.patidosa.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

@RestController
public class InfoController {

    @Value("${app.version:1.0.0}")
    private String appVersion;

    private final long startTime = System.currentTimeMillis();

    // Home page ("/") is served automatically from src/main/resources/static/index.html
    // by Spring Boot's default static resource handling - no mapping needed here.

    @GetMapping("/api/info")
    public Map<String, Object> info() throws Exception {
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("app", "patidosa");
        data.put("version", appVersion);
        data.put("hostname", InetAddress.getLocalHost().getHostName());
        data.put("uptime_seconds", (System.currentTimeMillis() - startTime) / 1000);
        data.put("server_time", Instant.now().toString());
        return data;
    }
}
