/**
 * Gets the current CPU usage percentage
 * @returns {number} CPU usage percentage
 */
function getCPUUsage() {
    const cpus = os.cpus();
    let totalIdle = 0;
    let totalTick = 0;
    cpus.forEach((cpu) => {
        for (const type in cpu.times) {
            totalTick += cpu.times[type];
        }
        totalIdle += cpu.times.idle;
    });
    return ((totalTick - totalIdle) / totalTick) * 100;
}

/**
 * Gets the current RAM usage percentage
 * @returns {number} RAM usage percentage
 */
function getRAMUsage() {
    const totalRAM = os.totalmem();
    const freeRAM = os.freemem();
    return ((totalRAM - freeRAM) / totalRAM) * 100;
}

/**
 * Gets the current CPU usage in raw ticks
 * @returns {number} CPU usage in raw ticks
 */
function getCPURaw() {
    const cpus = os.cpus();
    let totalIdle = 0;
    let totalTick = 0;
    cpus.forEach((cpu) => {
        for (const type in cpu.times) {
            totalTick += cpu.times[type];
        }
        totalIdle += cpu.times.idle;
    });
    return (totalTick - totalIdle);
}

/**
 * Gets the current RAM usage in raw bytes
 * @returns {number} RAM usage in raw bytes
 */
function getRAMRaw() {
    const totalRAM = os.totalmem();
    const freeRAM = os.freemem();
    return (totalRAM - freeRAM);
}

/**
 * Gets the current system information
 * @returns {object} System information
 */
exports('getSystemInfo', () => {
    return { cpuUsage: getCPUUsage(), ramUsage: getRAMUsage(), cpuRaw: getCPURaw(), ramRaw: getRAMRaw() }
})