# Java / Kotlin（Spring 系）参考

## Manifest 与指纹

- `pom.xml`：看 `<parent>`（spring-boot-starter-parent → Spring Boot 版本）、`<modules>`（多模块）、`<dependencies>`。`gradle/libs.versions.toml` 是版本目录。
- 多模块时：含 `spring-boot-maven-plugin` 或 `bootJar` 配置的模块是**启动模块**；`xxx-api`/`xxx-common` 通常是契约与工具模块。
- Kotlin 项目可能有 `build.gradle.kts`；Ktor 项目无 Spring 注解，以 `Application.kt` + `embeddedServer` 为入口。

## 入口定位

- Grep `@SpringBootApplication` → 主类，其 `main` 方法是启动点。多个命中 = 多个可启动服务（微服务/多应用）。
- 交叉验证：Dockerfile 的 ENTRYPOINT（通常是 `java -jar xxx.jar`）、`application.yml` 的 `spring.application.name`。

## 层级定位（Grep 模式）

| 层 | 模式 |
|---|---|
| Web | `@RestController|@Controller` + `@RequestMapping|@GetMapping|@PostMapping` |
| 业务 | `@Service`；常见 接口 + `XxxImpl` 惯例 |
| 数据 | `@Mapper`（MyBatis）、`JpaRepository|@Entity`（JPA）、`@Repository` |
| 配置 | `@Configuration`、`@ConfigurationProperties` |
| 切面/拦截 | `@Aspect`、`HandlerInterceptor`、`WebMvcConfigurer`、`@ControllerAdvice`（全局异常） |

- MyBatis 的真实 SQL 在 `resources/mapper/*.xml` 或注解 `@Select/@Insert` 里——分析数据访问时必看。
- Lombok 项目没有 getter/setter 样板；实体字段即表结构线索。

## 中间件与外部依赖识别

| 依赖/注解 | 说明 |
|---|---|
| spring-boot-starter-data-redis + `RedisTemplate`/`@Cacheable` | Redis 缓存；`RedissonClient` 是分布式锁 |
| spring-kafka `@KafkaListener` / spring-rabbit `@RabbitListener` / `@RocketMQMessageListener` | MQ 消费者 = 隐藏入口 |
| `@FeignClient` | 跨服务 HTTP 调用，调用链会跨服务继续 |
| spring-cloud-starter-gateway / nacos / eureka / consul | 网关与注册中心 → 微服务架构证据 |
| sentinel / resilience4j / seata | 限流熔断 / 分布式事务 |
| `@Scheduled`、`@XxlJob`、`@EnableScheduling` | 定时任务 = 隐藏入口 |
| spring-boot-starter-security / sa-token / jjwt / shiro | 认证鉴权链路，通常在 Filter/Interceptor |

## 配置文件

`application.yml|properties`（+ `application-{profile}` 区分环境）、`bootstrap.yml`（旧版 Spring Cloud）。数据源/Redis/MQ 地址都在这里。

## 读法要点

1. Controller 只看方法签名 + 注解（路径、入参出参 DTO）；**业务逻辑在 Service 实现里**。
2. Service 常是接口 + Impl：接口看职责契约，Impl 看实现。
3. 事务边界 `@Transactional` 是理解数据一致性的关键点。
4. 多模块项目先看模块划分（api/service/dao/ common），依赖方向通常是 controller → service → dao，出现反向即为异常。
