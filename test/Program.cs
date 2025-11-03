using System;

class Program
{
    static void Main()
    {
        Console.WriteLine("Hello from macOS, running on Windows!");
        Console.WriteLine($"Current Time: {DateTime.Now}");
        Console.WriteLine($"OS Version: {Environment.OSVersion}");
        Console.WriteLine($"64-bit OS: {Environment.Is64BitOperatingSystem}");
    }
}
