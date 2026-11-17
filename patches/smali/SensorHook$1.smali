.class Lcom/mokrun/app/xposed/SensorHook$1;
.super Lde/robv/android/xposed/XC_MethodHook;
.source "SensorHook.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/mokrun/app/xposed/SensorHook;->hookRealEventProbe(Ljava/lang/ClassLoader;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# direct methods
.method constructor <init>()V
    .locals 0

    .line 77
    invoke-direct {p0}, Lde/robv/android/xposed/XC_MethodHook;-><init>()V

    return-void
.end method


# virtual methods
.method protected beforeHookedMethod(Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;)V
    .locals 7

    const-string p0, "MokrRun: real sensor events -> "

    .line 80
    :try_start_0
    iget-object p1, p1, Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;->args:[Ljava/lang/Object;

    const/4 v0, 0x0

    aget-object p1, p1, v0

    .line 81
    instance-of v0, p1, Ljava/lang/Integer;

    if-eqz v0, :cond_2

    .line 82
    check-cast p1, Ljava/lang/Integer;

    .line 83
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    .line 84
    invoke-static {}, Lcom/mokrun/app/xposed/SensorHook;->access$000()Ljava/util/Map;

    move-result-object v2

    monitor-enter v2
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 85
    :try_start_1
    invoke-static {}, Lcom/mokrun/app/xposed/SensorHook;->access$000()Ljava/util/Map;

    move-result-object v3

    invoke-interface {v3, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    .line 86
    invoke-static {}, Lcom/mokrun/app/xposed/SensorHook;->access$000()Ljava/util/Map;

    move-result-object v4

    const/4 v5, 0x1

    if-eqz v3, :cond_0

    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I

    move-result v3

    add-int/2addr v5, v3

    :cond_0
    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v3

    invoke-interface {v4, p1, v3}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 87
    invoke-static {}, Lcom/mokrun/app/xposed/SensorHook;->access$100()J

    move-result-wide v3

    sub-long v3, v0, v3

    const-wide/16 v5, 0x2710

    cmp-long p1, v3, v5

    if-gez p1, :cond_1

    monitor-exit v2

    return-void

    .line 88
    :cond_1
    invoke-static {v0, v1}, Lcom/mokrun/app/xposed/SensorHook;->access$102(J)J

    .line 89
    new-instance p1, Ljava/lang/StringBuilder;

    invoke-direct {p1, p0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-static {}, Lcom/mokrun/app/xposed/SensorHook;->access$000()Ljava/util/Map;

    move-result-object p0

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    .line 90
    invoke-static {}, Lcom/mokrun/app/xposed/SensorHook;->access$000()Ljava/util/Map;

    move-result-object p0

    invoke-interface {p0}, Ljava/util/Map;->clear()V

    .line 91
    monitor-exit v2

    return-void

    :goto_0
    monitor-exit v2
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :try_start_2
    throw p0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    :catchall_0
    move-exception p0

    goto :goto_0

    :catchall_1
    :cond_2
    return-void
.end method
