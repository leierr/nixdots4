// CPU Monitor
const cpu = Variable(1000, {
  poll: [2000, () => {
    const top_output = Utils.exec('top -b -n 1'); // Assuming Utils.exec runs the shell command and returns output
    const cpuLine = top_output.split('\n').find(line => line.includes('Cpu(s)')); // Find the line containing CPU info
    if (cpuLine) {
      const cpuUsage = Math.ceil(100 - parseFloat(cpuLine.split(/\s+/)[7].replace(',', '.'))); // Extract CPU usage and convert to number
      return cpuUsage;
    }
    return 0; // Default to 0 if no CPU line found
  }],
});

// RAM Monitor
const ram = Variable(1000, {
  poll: [2000, () => {
    const free_output = Utils.exec('free'); // Assuming Utils.exec runs the shell command and returns output
    const memLine = free_output.split('\n').find(line => line.includes('Mem:')); // Find the line containing memory info
    if (memLine) {
      const memParts = memLine.split(/\s+/); // Split the line by spaces
      const totalMem = parseFloat(memParts[1]); // Extract total memory
      const usedMem = parseFloat(memParts[2]); // Extract used memory
      const memUsage = Math.ceil((usedMem / totalMem) * 100); // Calculate memory usage percentage
      return memUsage;
    }
    return 0; // Default to 0 if no memory line found
  }],
});

const cpu_monitor = () => Widget.Box({
  spacing: 0,
  class_name: "topbar_submodules_sysmetrics_cpu",
  children: [
    Widget.Icon('cpu-symbolic'),
    Widget.Label({ label: cpu.bind().as(value => value.toString() + '%') }),
  ],
});

const ram_monitor = () => Widget.Box({
  spacing: 0,
  class_name: "topbar_submodules_sysmetrics_ram",
  children: [
    Widget.Icon('ram-symbolic'),
    Widget.Label({ label: ram.bind().as(value => value.toString() + '%') }),
  ],
});

export { cpu_monitor, ram_monitor };
