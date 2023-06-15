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

// Function to get RAM usage
function getRAMUsage() {
    const totalRAM = os.totalmem();
    const freeRAM = os.freemem();
    return ((totalRAM - freeRAM) / totalRAM) * 100;
}

exports('getSystemInfo', () => {
    return { cpu: getCPUUsage(), ram: getRAMUsage() }
})