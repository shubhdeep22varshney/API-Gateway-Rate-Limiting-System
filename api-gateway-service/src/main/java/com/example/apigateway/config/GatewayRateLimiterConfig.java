package com.example.apigateway.config;

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import reactor.core.publisher.Mono;

@Configuration
public class GatewayRateLimiterConfig {

    @Bean
    public KeyResolver userKeyResolver() {
        return exchange -> exchange.getPrincipal()
                .map(principal -> {
                    if (principal instanceof JwtAuthenticationToken jwt) {
                        String user = jwt.getToken().getClaimAsString("preferred_username");
                        return "user:" + (user != null ? user : jwt.getName());
                    }
                    return "user:" + principal.getName();
                })
                .switchIfEmpty(Mono.fromSupplier(() -> {
                    var addr = exchange.getRequest().getRemoteAddress();
                    return "ip:" + (addr != null ? addr.getAddress().getHostAddress() : "unknown");
                }));
    }
}