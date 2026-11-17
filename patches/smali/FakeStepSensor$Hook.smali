.class public final Lcom/mokrun/app/xposed/FakeStepSensor$Hook;
.super Lde/robv/android/xposed/XC_MethodHook;
.source "FakeStepSensor.java"


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lde/robv/android/xposed/XC_MethodHook;-><init>()V

    return-void
.end method


# virtual methods
.method protected beforeHookedMethod(Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;)V
    .locals 3

    :try_start_0
    iget-object v0, p1, Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;->args:[Ljava/lang/Object;

    if-eqz v0, :try_end_0

    array-length v1, v0

    if-lez v1, :try_end_0

    const/4 v1, 0x0

    aget-object v0, v0, v1

    instance-of v1, v0, Ljava/lang/Integer;

    if-eqz v1, :try_end_0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I
    move-result v0

    const/16 v1, 0x13

    if-eq v0, v1, :try_end_0

    const/16 v1, 0x12

    if-eq v0, v1, :try_end_0

    const-string v2, "MokrRun getDefaultSensor hit step type"

    invoke-static {v2}, Lde/robv/android/xposed/XposedBridge;->log(Ljava/lang/String;)V

    invoke-static {}, Lcom/mokrun/app/xposed/FakeStepSensor;->fake()Landroid/hardware/Sensor;
    move-result-object v0

    if-eqz v0, :try_end_0

    invoke-virtual {p1, v0}, Lde/robv/android/xposed/XC_MethodHook$MethodHookParam;->setResult(Ljava/lang/Object;)V
    :try_end_0
    .catch Ljava/lang/Throwable; {:try_start_0 .. :try_end_0} :catch_0

    return-void

    :catch_0
    move-exception v0

    return-void
.end method