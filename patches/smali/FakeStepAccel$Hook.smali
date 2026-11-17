.class public final Lcom/mokrun/app/xposed/FakeStepAccel$Hook;
.super Lde/robv/android/xposed/XC_MethodHook;
.source "FakeStepAccel.java"

.field private static sDbg:I


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lde/robv/android/xposed/XC_MethodHook;-><init>()V

    return-void
.end method


# virtual methods
.method protected beforeHookedMethod(Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;)V
    .locals 14

    :diag_start
    sget v3, Lcom/mokrun/app/xposed/FakeStepAccel$Hook;->sDbg:I

    const/4 v4, 0x3

    if-ge v3, v4, :diag_done

    add-int/lit8 v4, v3, 0x1

    sput v4, Lcom/mokrun/app/xposed/FakeStepAccel$Hook;->sDbg:I

    iget-object v5, p1, Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;->args:[Ljava/lang/Object;

    array-length v5, v5

    invoke-static {v5}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;
    move-result-object v5

    invoke-static {v5}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    :diag_done

    :try_start_0
    iget-object v0, p1, Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;->args:[Ljava/lang/Object;

    array-length v1, v0

    const/4 v2, 0x4

    if-ge v1, v2, :end

    const/4 v2, 0x3

    aget-object v2, v0, v2

    instance-of v3, v2, Landroid/hardware/SensorEvent;

    if-eqz v3, :end

    check-cast v2, Landroid/hardware/SensorEvent;

    iget-object v3, v2, Landroid/hardware/SensorEvent;->sensor:Landroid/hardware/Sensor;

    invoke-virtual {v3}, Landroid/hardware/Sensor;->getType()I
    move-result v3

    const/4 v4, 0x1

    if-eq v3, v4, :chk_lin

    goto :fill

    :chk_lin
    const/16 v4, 0xa

    if-ne v3, v4, :end

    :fill
    const/4 v4, 0x1

    aget-object v4, v0, v4

    instance-of v5, v4, [F

    if-eqz v5, :end

    check-cast v4, [F

    array-length v5, v4

    const/4 v6, 0x3

    if-ge v5, v6, :end

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J
    move-result-wide v6

    const-wide/16 v8, 0x140

    rem-long/2addr v6, v8

    long-to-int v6, v6

    int-to-float v6, v6

    const v7, 0x43a00000

    div-float/2addr v6, v7

    const v7, 0x40c90fdb

    mul-float/2addr v6, v7

    float-to-double v8, v6

    invoke-static {v8, v9}, Ljava/lang/Math;->sin(D)D
    move-result-wide v8

    double-to-float v6, v8

    const v7, 0x3e19999a

    mul-float v7, v6, v7

    const/4 v8, 0x0

    aput v7, v4, v8

    const/4 v7, 0x0

    const/4 v8, 0x1

    aput v7, v4, v8

    const v7, 0x40200000

    mul-float/2addr v7, v6

    const v8, 0x411ccccd

    add-float/2addr v7, v8

    const/4 v8, 0x2

    aput v7, v4, v8
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :end
    return-void

    :catch_0
    move-exception v0

    return-void
.end method
