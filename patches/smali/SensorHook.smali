.class public final Lcom/mokrun/app/xposed/SensorHook;
.super Ljava/lang/Object;
.source "SensorHook.java"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/mokrun/app/xposed/SensorHook$RegHook;,
        Lcom/mokrun/app/xposed/SensorHook$UnregHook;
    }
.end annotation


# static fields
.field private static final TAG:Ljava/lang/String; = "MokrRun"

.field private static sInstalled:Z

.field private static sLastRealDump:J

.field private static final sListeners:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Landroid/hardware/SensorEventListener;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private static final sRealEvents:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field

.field private static final sSensors:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Landroid/hardware/SensorEventListener;",
            "Landroid/hardware/Sensor;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 2

    .line 33
    new-instance v0, Ljava/util/IdentityHashMap;

    invoke-direct {v0}, Ljava/util/IdentityHashMap;-><init>()V

    .line 34
    invoke-static {v0}, Ljava/util/Collections;->synchronizedMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0

    sput-object v0, Lcom/mokrun/app/xposed/SensorHook;->sListeners:Ljava/util/Map;

    .line 37
    new-instance v0, Ljava/util/IdentityHashMap;

    invoke-direct {v0}, Ljava/util/IdentityHashMap;-><init>()V

    .line 38
    invoke-static {v0}, Ljava/util/Collections;->synchronizedMap(Ljava/util/Map;)Ljava/util/Map;

    move-result-object v0

    sput-object v0, Lcom/mokrun/app/xposed/SensorHook;->sSensors:Ljava/util/Map;

    const/4 v0, 0x0

    .line 40
    sput-boolean v0, Lcom/mokrun/app/xposed/SensorHook;->sInstalled:Z

    .line 69
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/mokrun/app/xposed/SensorHook;->sRealEvents:Ljava/util/Map;

    const-wide/16 v0, 0x0

    .line 71
    sput-wide v0, Lcom/mokrun/app/xposed/SensorHook;->sLastRealDump:J

    return-void
.end method

.method private constructor <init>()V
    .locals 0

    .line 42
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic access$000()Ljava/util/Map;
    .locals 1

    .line 28
    sget-object v0, Lcom/mokrun/app/xposed/SensorHook;->sRealEvents:Ljava/util/Map;

    return-object v0
.end method

.method static synthetic access$100()J
    .locals 2

    .line 28
    sget-wide v0, Lcom/mokrun/app/xposed/SensorHook;->sLastRealDump:J

    return-wide v0
.end method

.method static synthetic access$102(J)J
    .locals 0

    .line 28
    sput-wide p0, Lcom/mokrun/app/xposed/SensorHook;->sLastRealDump:J

    return-wide p0
.end method

.method static synthetic access$200()Ljava/util/Map;
    .locals 1

    .line 28
    sget-object v0, Lcom/mokrun/app/xposed/SensorHook;->sListeners:Ljava/util/Map;

    return-object v0
.end method

.method static synthetic access$300()Ljava/util/Map;
    .locals 1

    .line 28
    sget-object v0, Lcom/mokrun/app/xposed/SensorHook;->sSensors:Ljava/util/Map;

    return-object v0
.end method

.method private static hookRealEventProbe(Ljava/lang/ClassLoader;)V
    .locals 2

    .line 75
    :try_start_0
    const-string v0, "android.hardware.SystemSensorManager$SensorEventQueue"

    invoke-static {v0, p0}, Lde/robv/android/xposed/XposedHelpers;->findClass(Ljava/lang/String;Ljava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object p0

    .line 77
    const-string v0, "dispatchSensorEvent"

    new-instance v1, Lcom/mokrun/app/xposed/SensorHook$1;

    invoke-direct {v1}, Lcom/mokrun/app/xposed/SensorHook$1;-><init>()V

    invoke-static {p0, v0, v1}, Lde/robv/android/xposed/XposedBridge;->hookAllMethods(Ljava/lang/Class;Ljava/lang/String;Lde/robv/android/xposed/XC_MethodHook;)Ljava/util/Set;

    .line 96
    const-string p0, "MokrRun: real sensor event probe installed"

    invoke-static {p0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    return-void

    :catchall_0
    move-exception p0

    .line 98
    new-instance v0, Ljava/lang/StringBuilder;

    const-string v1, "MokrRun: real sensor probe skipped ("

    invoke-direct {v0, v1}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string p0, ")"

    invoke-virtual {v0, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    return-void
.end method

.method public static install(Ljava/lang/ClassLoader;)V
    .locals 5

    .line 45
    sget-boolean v0, Lcom/mokrun/app/xposed/SensorHook;->sInstalled:Z

    if-nez v0, :cond_0

    const/4 v0, 0x1

    .line 46
    sput-boolean v0, Lcom/mokrun/app/xposed/SensorHook;->sInstalled:Z

    .line 47
    invoke-static {p0}, Lcom/mokrun/app/xposed/SensorHook;->hookRealEventProbe(Ljava/lang/ClassLoader;)V

    invoke-static {p0}, Lcom/mokrun/app/xposed/FakeStepSensor;->install(Ljava/lang/ClassLoader;)V

    invoke-static {p0}, Lcom/mokrun/app/xposed/FakeStepAccel;->install(Ljava/lang/ClassLoader;)V

    .line 48
    const-string v0, "android.hardware.SystemSensorManager"

    const-string v1, "android.hardware.SensorManager"

    filled-new-array {v0, v1}, [Ljava/lang/String;

    move-result-object v0

    const/4 v1, 0x0

    :goto_0
    const/4 v2, 0x2

    if-ge v1, v2, :cond_0

    .line 51
    :try_start_0
    aget-object v2, v0, v1

    invoke-static {v2, p0}, Lde/robv/android/xposed/XposedHelpers;->findClass(Ljava/lang/String;Ljava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v2

    .line 52
    const-string v3, "registerListener"

    new-instance v4, Lcom/mokrun/app/xposed/SensorHook$RegHook;

    invoke-direct {v4}, Lcom/mokrun/app/xposed/SensorHook$RegHook;-><init>()V

    invoke-static {v2, v3, v4}, Lde/robv/android/xposed/XposedBridge;->hookAllMethods(Ljava/lang/Class;Ljava/lang/String;Lde/robv/android/xposed/XC_MethodHook;)Ljava/util/Set;

    .line 53
    const-string v3, "unregisterListener"

    new-instance v4, Lcom/mokrun/app/xposed/SensorHook$UnregHook;

    invoke-direct {v4}, Lcom/mokrun/app/xposed/SensorHook$UnregHook;-><init>()V

    invoke-static {v2, v3, v4}, Lde/robv/android/xposed/XposedBridge;->hookAllMethods(Ljava/lang/Class;Ljava/lang/String;Lde/robv/android/xposed/XC_MethodHook;)Ljava/util/Set;

    .line 54
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "MokrRun: sensor hooks installed on "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    aget-object v3, v0, v1

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_1

    :catchall_0
    move-exception v2

    .line 56
    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "MokrRun: sensor hook failed on "

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    aget-object v4, v0, v1

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v4, " ("

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    const-string v2, ")"

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v2}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    :goto_1
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    :cond_0
    return-void
.end method

.method static pushStep(J)V
    .locals 11

    .line 153
    sget-object v0, Lcom/mokrun/app/xposed/SensorHook;->sListeners:Ljava/util/Map;

    invoke-interface {v0}, Ljava/util/Map;->isEmpty()Z

    move-result v1

    if-nez v1, :cond_2

    .line 156
    monitor-enter v0

    .line 157
    :try_start_0
    new-instance v1, Ljava/util/ArrayList;

    invoke-interface {v0}, Ljava/util/Map;->keySet()Ljava/util/Set;

    move-result-object v2

    invoke-direct {v1, v2}, Ljava/util/ArrayList;-><init>(Ljava/util/Collection;)V

    .line 158
    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_1

    .line 161
    :try_start_1
    const-class v0, Landroid/hardware/SensorEvent;

    const/4 v2, 0x1

    new-array v3, v2, [Ljava/lang/Class;

    sget-object v4, Ljava/lang/Integer;->TYPE:Ljava/lang/Class;

    const/4 v5, 0x0

    aput-object v4, v3, v5

    .line 162
    invoke-virtual {v0, v3}, Ljava/lang/Class;->getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v0

    .line 163
    invoke-virtual {v0, v2}, Ljava/lang/reflect/Constructor;->setAccessible(Z)V

    move v3, v5

    .line 164
    :goto_0
    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v4

    if-ge v3, v4, :cond_2

    .line 165
    invoke-interface {v1, v3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Landroid/hardware/SensorEventListener;

    .line 166
    sget-object v6, Lcom/mokrun/app/xposed/SensorHook;->sSensors:Ljava/util/Map;

    invoke-interface {v6, v4}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Landroid/hardware/Sensor;

    .line 167
    sget-object v7, Lcom/mokrun/app/xposed/SensorHook;->sListeners:Ljava/util/Map;

    invoke-interface {v7, v4}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/lang/Integer;

    if-eqz v6, :cond_1

    if-eqz v7, :cond_1

    .line 170
    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v8

    filled-new-array {v8}, [Ljava/lang/Object;

    move-result-object v8

    invoke-virtual {v0, v8}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Landroid/hardware/SensorEvent;

    .line 171
    iput-object v6, v8, Landroid/hardware/SensorEvent;->sensor:Landroid/hardware/Sensor;

    .line 172
    invoke-static {}, Ljava/lang/System;->nanoTime()J

    move-result-wide v9

    iput-wide v9, v8, Landroid/hardware/SensorEvent;->timestamp:J

    .line 173
    iput v5, v8, Landroid/hardware/SensorEvent;->accuracy:I

    .line 174
    iget-object v6, v8, Landroid/hardware/SensorEvent;->values:[F

    invoke-virtual {v7}, Ljava/lang/Integer;->intValue()I

    move-result v7

    const/16 v9, 0x13

    if-ne v7, v9, :cond_0

    long-to-float v7, p0

    goto :goto_1

    :cond_0
    const/high16 v7, 0x3f800000    # 1.0f

    :goto_1
    aput v7, v6, v5

    .line 175
    invoke-interface {v4, v8}, Landroid/hardware/SensorEventListener;->onSensorChanged(Landroid/hardware/SensorEvent;)V
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    :cond_1
    add-int/lit8 v3, v3, 0x1

    goto :goto_0

    :cond_2
    return-void

    :catchall_0
    move-exception p0

    .line 178
    new-instance p1, Ljava/lang/StringBuilder;

    const-string v0, "MokrRun: pushStep failed "

    invoke-direct {p1, v0}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {p1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    invoke-virtual {p1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p0

    invoke-static {p0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    return-void

    .line 158
    :goto_2
    :try_start_2
    monitor-exit v0
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_1

    throw p0

    :catchall_1
    move-exception p0

    goto :goto_2
.end method
