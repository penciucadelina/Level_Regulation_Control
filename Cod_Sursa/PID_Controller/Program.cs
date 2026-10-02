using System;
using System.Net;
using System.Net.Sockets;
using System.IO;

namespace PID_Controller
{
    class Program
    {
       
        private const double Kp = 39;       
        private const double Ki = 39 / 404.0;  
        private const double Ts = 0.1;     

        // factor integrare discreta
        private static readonly double Ki_Discrete = Ki * Ts;

        // ci
        private const double IntegratorInitialValue = 30.22;

        // saturatie
        private const double MaxOutput = 1000.0;
        private const double MinOutput = -1000.0;

        static void Main(string[] args)
        {
            // afisare parametri in consola
            Console.WriteLine($"P (Kp)       = {Kp}");
            Console.WriteLine($"I (Gain)     = {Ki:F6}");
            Console.WriteLine($"Ts           = {Ts} s");
           

            // pornire server tcp
            TcpListener server = new TcpListener(IPAddress.Any, 5000);
            server.Start();

            while (true)
            {
                try
                {
                    Console.WriteLine("astept conexiune pe portul 5000...");
                    // acceptare simulink
                    using (TcpClient client = server.AcceptTcpClient())
                    using (NetworkStream stream = client.GetStream())
                    using (BinaryReader reader = new BinaryReader(stream))
                    using (BinaryWriter writer = new BinaryWriter(stream))
                    {
                        Console.WriteLine("conectat!");
                        // intra in bucla de calcul
                        RunPILoop(reader, writer);
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"eroare conexiune: {ex.Message}");
                }
            }
        }

        private static void RunPILoop(BinaryReader reader, BinaryWriter writer)
        {
            double integral = IntegratorInitialValue;
            long step = 0;

            try
            {
                while (true)
                {
                    // citeste eroarea primita de la client
                    double error = reader.ReadDouble();

                    // calcul termen proportional
                    double P_term = Kp * error;

                    //  calcul termen integral
                    integral += Ki_Discrete * error;

                    // calcul iesire
                    double output = P_term + integral;

                    // saturare si anti-windup 
                    if (output > MaxOutput)
                    {
                        output = MaxOutput;
                        // daca e saturat si eroarea creste, anuleaza integrarea (anti-windup)
                        if (error > 0) integral -= Ki_Discrete * error;
                    }
                    else if (output < MinOutput)
                    {
                        output = MinOutput;
                        // la fel pt saturatia negativa
                        if (error < 0) integral -= Ki_Discrete * error;
                    }

                    // trimit rezultatul inapoi
                    writer.Write(output);

                    // afisare status o data la 10 pasi-1 sec
                    step++;
                    if (step % 10 == 0)
                        Console.WriteLine($"t={step * Ts:F1}s | eroare={error:F4} | comanda={output:F4}");
                }
            }
            catch (EndOfStreamException)
            {
                Console.WriteLine("clientul s-a deconectat");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"eroare in bucla: {ex.Message}");
            }
        }
    }
}