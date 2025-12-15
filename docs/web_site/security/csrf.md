# CSRF（跨站请求伪造）详解

## 🔍 CSRF 是什么？

**CSRF（Cross-Site Request Forgery，跨站请求伪造）** 是一种常见的网络攻击方式。攻击者诱骗用户在已登录的目标网站状态下，访问恶意网站或点击恶意链接，从而在用户不知情的情况下，以用户的身份执行非预期的操作。

### 攻击原理图示：
```
用户浏览器 ────── 登录 ──────→ 银行网站（已认证）
     │
     │ 访问恶意网站
     ↓
恶意网站 ─── 自动提交表单 ───→ 银行网站/转账（携带用户的Cookie）
```

## 🎯 CSRF 攻击示例

### 场景：银行转账
1. 用户登录银行网站 `bank.com`，获得登录 Cookie
2. 用户访问恶意网站 `evil.com`
3. 恶意网站包含自动提交的表单：
```html
<form action="https://bank.com/transfer" method="POST">
    <input type="hidden" name="to" value="hacker">
    <input type="hidden" name="amount" value="1000">
</form>
<script>document.forms[0].submit();</script>
```
4. 浏览器自动携带银行网站的 Cookie 发送请求，转账成功

## 🔧 前后端的 CSRF 防护机制

### 后端定义与实现

#### Spring Security 中的 CSRF 防护
```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf
                // 启用 CSRF 保护
                .csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
                // 忽略某些路径（可选）
                .ignoringRequestMatchers("/api/public/**", "/webhook/**")
            )
            .authorizeHttpRequests(auth -> auth
                .anyRequest().authenticated()
            );
        
        return http.build();
    }
}
```

#### CSRF Token 生成与验证流程
```java
// Spring Security 内部流程：
public class CsrfFilter {
    
    // 1. 生成 Token
    public void doFilter(ServletRequest request, ServletResponse response) {
        CsrfToken token = tokenRepository.generateToken(request);
        tokenRepository.saveToken(token, request, response);
        
        // 2. 验证请求
        if (requiresProtection(request)) {
            CsrfToken storedToken = tokenRepository.loadToken(request);
            if (!storedToken.equals(requestToken)) {
                // 验证失败，拒绝请求
                throw new InvalidCsrfTokenException("Invalid CSRF token");
            }
        }
    }
}
```

### 前端定义与实现

#### CSRF Token 的获取与传递

**方式一：从 Cookie 读取并设置到 Header**
```javascript
// 获取 CSRF Token 的工具函数
function getCsrfToken() {
    const name = 'XSRF-TOKEN';
    const cookies = document.cookie.split(';');
    for (let cookie of cookies) {
        const [key, value] = cookie.trim().split('=');
        if (key === name) {
            return decodeURIComponent(value);
        }
    }
    return null;
}

// 使用 Fetch API
async function makeRequest(url, data) {
    const csrfToken = getCsrfToken();
    
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-XSRF-TOKEN': csrfToken  // 关键：在请求头中传递
        },
        body: JSON.stringify(data),
        credentials: 'include'  // 包含 Cookie
    });
    
    return response.json();
}
```

**方式二：使用 Axios 拦截器自动处理**
```javascript
import axios from 'axios';

// 创建 axios 实例
const apiClient = axios.create({
    baseURL: '/api',
    withCredentials: true  // 重要：允许携带 Cookie
});

// 请求拦截器：自动添加 CSRF Token
apiClient.interceptors.request.use(config => {
    const csrfToken = getCsrfToken();
    
    // 对修改操作添加 CSRF Token
    if (['post', 'put', 'patch', 'delete'].includes(config.method?.toLowerCase()) && csrfToken) {
        config.headers['X-XSRF-TOKEN'] = csrfToken;
    }
    
    return config;
});

// 响应拦截器：处理 CSRF Token 过期等情况
apiClient.interceptors.response.use(
    response => response,
    error => {
        if (error.response?.status === 403 && 
            error.response.data?.contains('CSRF')) {
            // CSRF Token 无效，重新获取页面或 token
            window.location.reload();
        }
        return Promise.reject(error);
    }
);
```

**方式三：传统表单方式**
```html
<!-- Thymeleaf 模板自动处理 -->
<form method="post" action="/submit">
    <input type="hidden" 
           th:name="${_csrf.parameterName}" 
           th:value="${_csrf.token}" />
    <input type="text" name="data" />
    <button type="submit">提交</button>
</form>

<!-- 手动处理 -->
<form id="myForm" method="post" action="/submit">
    <input type="text" name="data" />
</form>

<script>
document.getElementById('myForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    const csrfToken = getCsrfToken();
    
    fetch(this.action, {
        method: 'POST',
        headers: {
            'X-XSRF-TOKEN': csrfToken
        },
        body: formData,
        credentials: 'include'
    });
});
</script>
```

## 🛡️ CSRF Token 的工作流程

### 完整交互流程：
```
1. 用户访问页面 ────→ 后端生成 CSRF Token
        ↓
2. 后端返回页面，设置 Cookie: XSRF-TOKEN=abc123
        ↓
3. 前端发起修改请求，Header: X-XSRF-TOKEN: abc123
        ↓
4. 后端验证 Token 匹配 ────→ 成功：处理请求
                            失败：返回 403 错误
```

### 双重 Cookie 防御模式
```java
// Spring Security 配置双重 Cookie 模式
@Bean
public CsrfTokenRepository csrfTokenRepository() {
    CookieCsrfTokenRepository repository = CookieCsrfTokenRepository.withHttpOnlyFalse();
    repository.setCookieCustomizer(cookie -> {
        cookie.setPath("/");
        cookie.setSecure(true);  // 仅 HTTPS
        cookie.setSameSite("Lax");  // 同站策略
    });
    return repository;
}
```

## 📊 CSRF 防护策略对比

| 防护方式            | 实现复杂度 | 安全性 | 适用场景                  |
| ------------------- | ---------- | ------ | ------------------------- |
| **CSRF Token**      | 中等       | 高     | 传统 Web 应用、前后端分离 |
| **SameSite Cookie** | 低         | 中高   | 现代浏览器支持的应用      |
| **双重提交 Cookie** | 低         | 中     | 简单应用                  |
| **验证 Referer**    | 低         | 中     | 辅助防护                  |

## 🔄 SameSite Cookie 替代方案

```java
// 使用 SameSite Cookie 作为 CSRF 防护的补充或替代
@Configuration
public class CookieConfig {
    
    @Bean
    public CookieSerializer cookieSerializer() {
        DefaultCookieSerializer serializer = new DefaultCookieSerializer();
        serializer.setSameSite("Lax");  // 或 "Strict"
        serializer.setUseSecureCookie(true);
        return serializer;
    }
}
```

## 💡 最佳实践建议

### 后端最佳实践：
1. **默认启用 CSRF 保护**，对修改操作进行防护
2. **为公开 API 配置例外**（如：`/api/public/**`）
3. **使用安全的 Token 存储方式**（HttpOnly + Secure）
4. **定期更新 Token**，防止重放攻击

### 前端最佳实践：
1. **对所有修改操作自动添加 CSRF Token**
2. **正确处理 Token 过期**，提供友好的重新认证流程
3. **避免在 URL 中传递 Token**，防止日志泄露
4. **使用安全的通信协议**（HTTPS）

## 🎯 总结

CSRF 是一种利用用户已认证状态发起的攻击，前后端需要协同防护：

- **后端**：生成、存储、验证 CSRF Token
- **前端**：获取 Token 并在请求中正确传递
- **协作**：通过 Cookie + Header 的双重验证机制

这种机制确保了只有来自合法源的请求才能被执行，有效防止了跨站请求伪造攻击。