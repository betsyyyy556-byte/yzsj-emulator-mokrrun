.class public final Lcom/mokrun/app/xposed/FakeStepSensor;
.super Ljava/lang/Object;
.source "FakeStepSensor.java"


# static fields
.field private static sFake:Landroid/hardware/Sensor;


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static fake()Landroid/hardware/Sensor;
    .locals 5

    sget-object v0, Lcom/mokrun/app/xposed/FakeStepSensor;->sFake:Landroid/hardware/Sensor;

    if-eqz v0, :cond_build

    return-object v0

    :cond_build
    :try_start_0
    const-class v0, Landroid/hardware/Sensor;

    const/4 v1, 0x0

    invoke-static {v0, v1}, Lde/robv/android/xposed/XposedHelpers;->newInstance(Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;
    move-result-object v0

    check-cast v0, Landroid/hardware/Sensor;

    const-string v1, "mName"

    const-string v2, "MokrRun Step Counter"

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setObjectField(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V

    const-string v1, "mVendor"

    const-string v2, "MokrRun"

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setObjectField(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V

    const-string v1, "mStringType"

    const-string v2, "android.sensor.step_counter"

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setObjectField(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/Object;)V

    const-string v1, "mType"

    const/16 v2, 0x13

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setIntField(Ljava/lang/Object;Ljava/lang/String;I)V

    const-string v1, "mVersion"

    const/4 v2, 0x1

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setIntField(Ljava/lang/Object;Ljava/lang/String;I)V

    const-string v1, "mHandle"

    const v2, 0x4d4b5253

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setIntField(Ljava/lang/Object;Ljava/lang/String;I)V

    const-string v1, "mMinDelay"

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setIntField(Ljava/lang/Object;Ljava/lang/String;I)V

    const-string v1, "mMaxDelay"

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setIntField(Ljava/lang/Object;Ljava/lang/String;I)V

    const-string v1, "mFlags"

    const/4 v2, 0x0

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setIntField(Ljava/lang/Object;Ljava/lang/String;I)V

    const-string v1, "mMaxRange"

    const v2, 0x49742400    # 1000000.0f

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setFloatField(Ljava/lang/Object;Ljava/lang/String;F)V

    const-string v1, "mResolution"

    const/high16 v2, 0x3f800000    # 1.0f

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setFloatField(Ljava/lang/Object;Ljava/lang/String;F)V

    const-string v1, "mPower"

    const/high16 v2, 0x3f000000    # 0.5f

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedHelpers;->setFloatField(Ljava/lang/Object;Ljava/lang/String;F)V

    sput-object v0, Lcom/mokrun/app/xposed/FakeStepSensor;->sFake:Landroid/hardware/Sensor;
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    sget-object v0, Lcom/mokrun/app/xposed/FakeStepSensor;->sFake:Landroid/hardware/Sensor;

    return-object v0

    :catch_0
    move-exception v0

    const/4 v0, 0x0

    return-object v0
.end method

.method public static install(Ljava/lang/ClassLoader;)V
    .locals 4

    :try_start_0
    const-string v3, "MokrRun FakeStepSensor enter"
    invoke-static {v3}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    const-string v0, "android.hardware.SensorManager"
    invoke-static {v0}, Lcom/mokrun/app/xposed/FakeStepSensor;->hookClass(Ljava/lang/String;)V

    const-string v0, "android.hardware.SystemSensorManager"
    invoke-static {v0}, Lcom/mokrun/app/xposed/FakeStepSensor;->hookClass(Ljava/lang/String;)V
    invoke-static {p0}, Lcom/mokrun/app/xposed/FakeStepAccel;->install(Ljava/lang/ClassLoader;)V

    return-void

    :catch_0
    move-exception v0

    const-string v3, "MokrRun hookClass failed"
    invoke-static {v3}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    return-void
.end method

.method private static hookClass(Ljava/lang/String;)V
    .locals 4

    :try_start_0
    invoke-static {p0}, Ljava/lang/Class;->forName(Ljava/lang/String;)Ljava/lang/Class;
    move-result-object v0

    if-nez v0, :ret

    const-string v1, "getDefaultSensor"

    new-instance v2, Lcom/mokrun/app/xposed/FakeStepSensor$Hook;

    invoke-direct {v2}, Lcom/mokrun/app/xposed/FakeStepSensor$Hook;-><init>()V

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedBridge;->hookAllMethods(Ljava/lang/Class;Ljava/lang/String;Lde/robv/android/xposed/XC_MethodHook;)Ljava/util/Set;

    const-string v1, "getSensorList"

    new-instance v2, Lcom/mokrun/app/xposed/FakeStepSensor$ListHook;

    invoke-direct {v2}, Lcom/mokrun/app/xposed/FakeStepSensor$ListHook;-><init>()V

    invoke-static {v0, v1, v2}, Lde/robv/android/xposed/XposedBridge;->hookAllMethods(Ljava/lang/Class;Ljava/lang/String;Lde/robv/android/xposed/XC_MethodHook;)Ljava/util/Set;

    const-string v3, "MokrRun hooks installed on a sensor class"
    invoke-static {v3}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    :ret
    return-void

    :catch_0
    move-exception v0

    const-string v3, "MokrRun hookClass failed"
    invoke-static {v3}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    return-void
.end method