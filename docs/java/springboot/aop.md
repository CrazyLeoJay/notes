Spring AOP 提供了丰富的注解来实现切片编程。以下是主要的AOP注解及其作用说明和基本使用示例：

## 1. 核心注解概览

| 注解              | 作用             | 执行时机                   |
| ----------------- | ---------------- | -------------------------- |
| `@Aspect`         | 声明一个切面类   | -                          |
| `@Pointcut`       | 定义切入点表达式 | -                          |
| `@Before`         | 前置通知         | 方法执行前                 |
| `@After`          | 后置通知         | 方法执行后（无论成功与否） |
| `@AfterReturning` | 返回通知         | 方法成功返回后             |
| `@AfterThrowing`  | 异常通知         | 方法抛出异常后             |
| `@Around`         | 环绕通知         | 方法执行前后               |
| `@DeclareParents` | 引入通知         | 为类添加新接口             |

## 2. 详细注解说明和示例

### 2.1 `@Aspect` - 声明切面

**作用**：标记一个类为切面类

```java
@Aspect
@Component
public class LoggingAspect {
    // 切面内容
}
```

### 2.2 `@Pointcut` - 定义切入点

**作用**：定义可重用的切入点表达式

```java
@Aspect
@Component
public class CommonPointcuts {
    
    // 匹配service包下所有方法
    @Pointcut("execution(* com.example.service..*(..))")
    public void serviceLayer() {}
    
    // 匹配所有public方法
    @Pointcut("execution(public * *(..))")
    public void publicMethod() {}
    
    // 匹配带有特定注解的方法
    @Pointcut("@annotation(com.example.annotation.Loggable)")
    public void loggableMethod() {}
    
    // 匹配在指定注解的类中的方法
    @Pointcut("@within(org.springframework.stereotype.Service)")
    public void withinService() {}
    
    // 组合切入点
    @Pointcut("serviceLayer() && publicMethod()")
    public void publicServiceMethod() {}
}
```

### 2.3 `@Before` - 前置通知

**作用**：在目标方法执行前执行

```java
@Aspect
@Component
public class BeforeAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(BeforeAspect.class);
    
    @Before("execution(* com.example.service.UserService.*(..))")
    public void beforeUserServiceMethod(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        
        logger.info("准备执行方法: {}，参数: {}", methodName, Arrays.toString(args));
        
        // 参数校验示例
        if (args.length > 0 && args[0] == null) {
            throw new IllegalArgumentException("参数不能为null");
        }
    }
    
    // 使用预定义的切入点
    @Before("com.example.aspect.CommonPointcuts.serviceLayer()")
    public void beforeServiceMethod(JoinPoint joinPoint) {
        logger.debug("Service方法执行前: {}", joinPoint.getSignature());
    }
}
```

### 2.4 `@After` - 后置通知

**作用**：在目标方法执行后执行（无论是否抛出异常）

```java
@Aspect
@Component
public class AfterAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(AfterAspect.class);
    
    @After("execution(* com.example.service.*.*(..))")
    public void afterServiceMethod(JoinPoint joinPoint) {
        String methodName = joinPoint.getSignature().getName();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        
        logger.info("方法执行完成: {}.{}", className, methodName);
        
        // 资源清理示例
        cleanupResources();
    }
    
    private void cleanupResources() {
        // 清理临时资源、关闭连接等
    }
}
```

### 2.5 `@AfterReturning` - 返回通知

**作用**：在目标方法成功返回后执行

```java
@Aspect
@Component
public class AfterReturningAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(AfterReturningAspect.class);
    
    // 基本用法
    @AfterReturning("execution(* com.example.service.UserService.getUser(..))")
    public void afterReturningGetUser(JoinPoint joinPoint) {
        logger.info("成功获取用户信息");
    }
    
    // 获取返回值
    @AfterReturning(
        pointcut = "execution(* com.example.service.*.find*(..))",
        returning = "result"
    )
    public void afterReturningFindMethod(JoinPoint joinPoint, Object result) {
        String methodName = joinPoint.getSignature().getName();
        
        if (result instanceof Collection) {
            Collection<?> collection = (Collection<?>) result;
            logger.info("查询方法 {} 返回了 {} 条记录", methodName, collection.size());
        } else if (result != null) {
            logger.info("查询方法 {} 返回了结果: {}", methodName, result);
        } else {
            logger.warn("查询方法 {} 返回了null", methodName);
        }
        
        // 结果后处理示例
        processResult(result);
    }
    
    private void processResult(Object result) {
        // 对结果进行后处理，如缓存、统计等
    }
}
```

### 2.6 `@AfterThrowing` - 异常通知

**作用**：在目标方法抛出异常后执行

```java
@Aspect
@Component
public class AfterThrowingAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(AfterThrowingAspect.class);
    
    // 捕获所有异常
    @AfterThrowing("execution(* com.example.service.*.*(..))")
    public void afterThrowingServiceMethod(JoinPoint joinPoint) {
        logger.error("Service方法执行出现异常: {}", joinPoint.getSignature());
    }
    
    // 捕获特定异常并获取异常对象
    @AfterThrowing(
        pointcut = "execution(* com.example.service.*.*(..))",
        throwing = "ex"
    )
    public void afterThrowingWithException(JoinPoint joinPoint, Exception ex) {
        String methodName = joinPoint.getSignature().getName();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        
        logger.error("方法 {}.{} 执行异常: {}", className, methodName, ex.getMessage(), ex);
        
        // 异常处理：发送告警、记录详细日志等
        sendAlert(className, methodName, ex);
    }
    
    // 只捕获特定类型的异常
    @AfterThrowing(
        pointcut = "execution(* com.example.service.*.*(..))",
        throwing = "ex"
    )
    public void afterThrowingBusinessException(JoinPoint joinPoint, BusinessException ex) {
        logger.warn("业务异常: {} - {}", joinPoint.getSignature(), ex.getMessage());
        
        // 业务异常的特殊处理
        handleBusinessException(ex);
    }
    
    private void sendAlert(String className, String methodName, Exception ex) {
        // 发送告警邮件、短信等
    }
    
    private void handleBusinessException(BusinessException ex) {
        // 业务异常处理逻辑
    }
}
```

### 2.7 `@Around` - 环绕通知

**作用**：最强大的通知类型，可以控制方法的执行

```java
@Aspect
@Component
public class AroundAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(AroundAspect.class);
    
    @Around("execution(* com.example.service.*.*(..))")
    public Object aroundServiceMethod(ProceedingJoinPoint joinPoint) throws Throwable {
        String methodName = joinPoint.getSignature().getName();
        String className = joinPoint.getTarget().getClass().getSimpleName();
        
        // 方法执行前
        logger.info("开始执行 {}.{}", className, methodName);
        
        // 记录参数
        if (logger.isDebugEnabled()) {
            Object[] args = joinPoint.getArgs();
            logger.debug("方法参数: {}", Arrays.toString(args));
        }
        
        // 性能监控
        StopWatch stopWatch = new StopWatch();
        stopWatch.start();
        
        try {
            // 执行目标方法
            Object result = joinPoint.proceed();
            stopWatch.stop();
            
            // 方法成功执行后
            long executionTime = stopWatch.getTotalTimeMillis();
            logger.info("成功执行 {}.{} - 耗时: {}ms", className, methodName, executionTime);
            
            // 慢方法警告
            if (executionTime > 1000) {
                logger.warn("方法执行缓慢: {}.{} 耗时 {}ms", className, methodName, executionTime);
            }
            
            return result;
            
        } catch (Exception e) {
            stopWatch.stop();
            logger.error("执行失败 {}.{} - 耗时: {}ms - 异常: {}", 
                        className, methodName, stopWatch.getTotalTimeMillis(), e.getMessage());
            throw e;
        }
    }
    
    // 缓存示例
    @Around("@annotation(com.example.annotation.Cacheable)")
    public Object aroundCacheableMethod(ProceedingJoinPoint joinPoint) throws Throwable {
        String cacheKey = generateCacheKey(joinPoint);
        
        // 尝试从缓存获取
        Object cachedValue = cache.get(cacheKey);
        if (cachedValue != null) {
            logger.debug("缓存命中: {}", cacheKey);
            return cachedValue;
        }
        
        // 执行方法并缓存结果
        Object result = joinPoint.proceed();
        cache.put(cacheKey, result);
        logger.debug("缓存设置: {}", cacheKey);
        
        return result;
    }
    
    private String generateCacheKey(ProceedingJoinPoint joinPoint) {
        // 生成缓存key的逻辑
        return joinPoint.getSignature().toShortString() + Arrays.hashCode(joinPoint.getArgs());
    }
}
```

### 2.8 `@DeclareParents` - 引入通知

**作用**：为目标类引入新的接口和实现

```java
@Aspect
@Component
public class IntroductionAspect {
    
    // 为所有Service引入监控接口
    @DeclareParents(
        value = "com.example.service.*+",
        defaultImpl = DefaultMonitorable.class
    )
    public Monitorable monitorable;
}

// 监控接口
public interface Monitorable {
    void setMonitorEnabled(boolean enabled);
    boolean isMonitorEnabled();
    void logStatus();
}

// 默认实现
public class DefaultMonitorable implements Monitorable {
    private boolean monitorEnabled = true;
    
    @Override
    public void setMonitorEnabled(boolean enabled) {
        this.monitorEnabled = enabled;
    }
    
    @Override
    public boolean isMonitorEnabled() {
        return monitorEnabled;
    }
    
    @Override
    public void logStatus() {
        System.out.println("监控状态: " + (monitorEnabled ? "启用" : "禁用"));
    }
}

// 使用示例
@Service
public class UserService {
    // 自动获得Monitorable接口的方法
}

// 在代码中使用
@Autowired
private UserService userService;

public void example() {
    // 类型转换后使用引入的方法
    Monitorable monitorable = (Monitorable) userService;
    monitorable.logStatus();
}
```

## 3. 综合使用示例

### 完整的日志切面

```java
@Aspect
@Component
public class ComprehensiveLoggingAspect {
    
    private static final Logger logger = LoggerFactory.getLogger(ComprehensiveLoggingAspect.class);
    
    // 定义各种切入点
    @Pointcut("execution(* com.example.controller..*(..))")
    public void controllerLayer() {}
    
    @Pointcut("execution(* com.example.service..*(..))")
    public void serviceLayer() {}
    
    @Pointcut("execution(* com.example.repository..*(..))")
    public void repositoryLayer() {}
    
    @Pointcut("@annotation(org.springframework.web.bind.annotation.GetMapping)")
    public void getMapping() {}
    
    @Pointcut("@annotation(org.springframework.web.bind.annotation.PostMapping)")
    public void postMapping() {}
    
    // Controller层日志
    @Before("controllerLayer()")
    public void logControllerAccess(JoinPoint joinPoint) {
        logger.info("Controller访问: {}", joinPoint.getSignature().getName());
    }
    
    // Service层性能监控
    @Around("serviceLayer()")
    public Object monitorServicePerformance(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        try {
            return joinPoint.proceed();
        } finally {
            long duration = System.currentTimeMillis() - start;
            if (duration > 500) {
                logger.warn("Service方法执行缓慢: {} - {}ms", 
                           joinPoint.getSignature(), duration);
            }
        }
    }
    
    // Repository层异常处理
    @AfterThrowing(pointcut = "repositoryLayer()", throwing = "ex")
    public void handleRepositoryException(JoinPoint joinPoint, Exception ex) {
        logger.error("数据访问异常: {} - {}", joinPoint.getSignature(), ex.getMessage());
    }
    
    // HTTP GET请求日志
    @AfterReturning(pointcut = "getMapping()", returning = "result")
    public void logGetRequest(JoinPoint joinPoint, Object result) {
        logger.debug("GET请求处理完成: {} - 返回: {}", 
                    joinPoint.getSignature().getName(), result);
    }
}
```

## 4. 配置启用AOP

```java
@Configuration
@EnableAspectJAutoProxy
public class AopConfig {
    // AOP自动代理配置
}
```

## 5. 最佳实践

1. **合理使用通知类型**：
   - 简单日志用 `@Before`/`@After`
   - 需要处理返回值用 `@AfterReturning`
   - 需要处理异常用 `@AfterThrowing`
   - 复杂逻辑用 `@Around`

2. **性能考虑**：
   - 在切面中避免耗时操作
   - 使用合适的日志级别
   - 生产环境减少DEBUG日志

3. **切入点优化**：
   - 使用精确的切入点表达式
   - 重用 `@Pointcut` 定义
   - 避免过于宽泛的匹配

这些注解和示例涵盖了Spring AOP切片编程的主要功能，可以根据实际需求组合使用。