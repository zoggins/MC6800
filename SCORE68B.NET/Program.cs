using System;
using System.IO;

namespace Score68B.Net
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length < 1)
            {
                Console.WriteLine(string.Format("Usage: Score68B.Net.exe <input file> [Tempo Value]", args[0]));
                return;
            }

            double tempoControl = 1.2;
            if (args.Length == 2)
            {
                if (!double.TryParse(args[1], out tempoControl))
                {
                    Console.WriteLine(string.Format("Couldn't parse tempo control value {0} as double.", args[1]));
                }
            }

            string data;
            try
            {
                data =File.ReadAllText(args[0]);
            }
            catch(Exception)
            {
                Console.WriteLine(string.Format("Couldn't open {0} for reading.", args[0]));
                return;
            }

            using (StringReader reader = new StringReader(data))
            {
                var v = 0;
                string line = string.Empty;

                do
                {
                    line = reader.ReadLine();
                    if (line != null)
                    {
                        line = line.Trim();
                        var columns = line.Split(' ', '\t');
                        if (columns.Length > 2)
                        {
                            line = "";
                            for (int i = 2; i < columns.Length; ++i)
                            {
                                line += columns[i];
                                line += ' ';
                            }
                        }

                        if (columns.Length > 2 && columns[1].Trim().ToUpper() == "DATA")
                        {
                            var notes = line.Split(",");
                            foreach (var note in notes)
                            {
                                double k1 = Math.Pow(2.0, (1.0 / 12.0));
                                double k6 = tempoControl;
                                k6 = k6 * 15 / 7;
                                int e1 = 0;
                                int c = 0;
                                double n = 100;
                                double m = 100;
                                double p = 100;
                                double t = 100;

                                var trimmedNote = note.Trim();

                                var a = trimmedNote.Substring(0, 1)[0];
                                var e = 100;
                                switch (a)
                                {
                                    case '5':
                                        e = 0;
                                        break;
                                    case 'R':
                                        e = 1 * 16;
                                        break;
                                    case 'S':
                                        e = 2 * 16;
                                        break;
                                    case 'L':
                                        e = 3 * 16;
                                        break;
                                    case '1':
                                        e = 4 * 16;
                                        break;
                                    case '2':
                                        e = 5 * 16;
                                        break;
                                    case '3':
                                        e = 6 * 16;
                                        break;
                                    case '4':
                                        e = 7 * 16;
                                        break;
                                }

                                if (e != 100)
                                {
                                    e1 = e;
                                    trimmedNote = trimmedNote.Substring(1);
                                    a = trimmedNote.Substring(0, 1)[0];
                                }

                                c++;
                                switch (a)
                                {
                                    case 'A':
                                        n = 1;
                                        break;
                                    case 'B':
                                        n = 3;
                                        break;
                                    case 'C':
                                        n = 4;
                                        break;
                                    case 'D':
                                        n = 6;
                                        break;
                                    case 'E':
                                        n = 8;
                                        break;
                                    case 'F':
                                        n = 9;
                                        break;
                                    case 'G':
                                        n = 11;
                                        break;
                                    case 'X':
                                        Console.WriteLine("0");
                                        return;
                                    default:
                                        ReportError(v, trimmedNote, c);
                                        return;
                                }

                                c++;
                                a = trimmedNote.Substring(1, 1)[0];
                                switch (a)
                                {
                                    case '!':
                                        m = n - 1;
                                        break;
                                    case '#':
                                        m = n + 1;
                                        break;
                                    case ' ':
                                        m = n;
                                        break;
                                    default:
                                        ReportError(v, trimmedNote, c);
                                        return;
                                }

                                c++;
                                a = trimmedNote.Substring(2, 1)[0];
                                switch (a)
                                {
                                    case '1':
                                        p = m;
                                        break;
                                    case '2':
                                        p = m + 12;
                                        break;
                                    case '3':
                                        p = m + 24;
                                        break;
                                    default:
                                        ReportError(v, trimmedNote, c);
                                        return;
                                }

                                c++;
                                a = trimmedNote.Substring(3, 1)[0];
                                switch (a)
                                {
                                    case 'S':
                                        t = 16;
                                        break;
                                    case 'E':
                                        t = 8;
                                        break;
                                    case 'Q':
                                        t = 4;
                                        break;
                                    case 'H':
                                        t = 2;
                                        break;
                                    case 'W':
                                        t = 1;
                                        break;
                                    default:
                                        ReportError(v, trimmedNote, c);
                                        return;
                                }

                                if (trimmedNote.Length == 5)
                                {
                                    c++;
                                    a = trimmedNote.Substring(4, 1)[0];
                                    if (a == '.')
                                        t = 2 * t / 3;
                                }
                                double f1 = 220.0 * (Math.Pow(k1, (p - 1)));
                                double t1 = Math.Pow(10.0, 6.0 / (2.0 * f1));
                                double k3 = (t1 * 1.7971 / 2.0 - 185.0) / 6.0;
                                double k4 = f1 / (k6 * t);
                                int d3 = Convert.ToInt32(k4);
                                int d4 = 2 * d3 - 2 * Convert.ToInt32(d3 / 2);
                                var d5 = Convert.ToInt32(d4 / 256.0);
                                int d6 = d5 + e1;
                                int d7 = d4 - d5 * 256;

                                Console.WriteLine("{0:X2} {1:X2} {2:X2}", (byte)(Convert.ToInt32(k3 + .5)), d6, d7);

                                v++;
                            }
                        }

                    }
                } while (line != null) ;
            }

        }

        private static void ReportError(int v, string trimmedNote, int c)
        {
            Console.WriteLine(string.Format("ERROR IN NOTE #{0}\nDATA STRING {1}\nCHARACTER #{2}", v, trimmedNote, c));
        }
    }
}
