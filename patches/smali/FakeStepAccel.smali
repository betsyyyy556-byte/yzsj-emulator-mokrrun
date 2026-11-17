.class public final Lcom/mokrun/app/xposed/FakeStepAccel;
.super Ljava/lang/Object;
.source "FakeStepAccel.java"


# static fields
.field private static sInstalled:Z


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static install(Ljava/lang/ClassLoader;)V
    .locals 3

    :try_start_0
    const-string v0, "MokrRun FakeStepAccel enter"

    invoke-static {v0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    sget-boolean v0, Lcom/mokrun/app/xposed/FakeStepAccel;->sInstalled:Z

    if-eqz v0, :go

    return-void

    :go
    const/4 v0, 0x1

    sput-boolean v0, Lcom/mokrun/app/xposed/FakeStepAccel;->sInstalled:Z

    const-string v0, "accel s2"

    invoke-static {v0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    const-string v0, "android.hardware.SystemSensorManager$SensorEventQueue"

    invoke-static {v0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v0

    const-string v1, "accel s3"

    invoke-static {v1}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    const-string v1, "dispatchSensorEvent"

    new-instance v2, Lcom/mokrun/app/xposed/FakeStepAccel$Hook;

    invoke-direct {v2}, Lcom/mokrun/app/xposed/FakeStepAccel$Hook;-><init>()V

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedBridge;->hookAllMethods(Ljava/lang/Class;Ljava/lang/String;Lde/robv/android/xposed/XC_MethodHook;)Ljava/util/Set;

    const-string v0, "accel s4"

    invoke-static {v0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    const-string v0, "MokrRun accel waveform hook installed"

    invoke-static {v0}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :ret
    return-void

    :catch_0
    move-exception v0

    const-string v1, "MokrRun accel waveform hook FAILED"

    invoke-static {v1}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    return-void
.end method