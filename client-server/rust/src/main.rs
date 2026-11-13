use std::env;
use std::io::{BufRead, BufReader, Write};
use std::net::{TcpListener, TcpStream};
use std::thread;

fn handle_client(mut stream: TcpStream) {
    let reader_stream = match stream.try_clone() {
        Ok(value) => value,
        Err(error) => {
            eprintln!("Не удалось создать поток чтения: {error}");
            return;
        }
    };
    let mut reader = BufReader::new(reader_stream);
    let mut request = String::new();

    if let Err(error) = reader.read_line(&mut request) {
        eprintln!("Ошибка чтения: {error}");
        return;
    }

    let number: i64 = match request.trim().parse() {
        Ok(value) => value,
        Err(_) => {
            let _ = stream.write_all("Ошибка: нужно передать целое число\n".as_bytes());
            return;
        }
    };

    let response = match number.checked_mul(number) {
        Some(value) => format!("{value}\n"),
        None => "Ошибка: квадрат числа не помещается в i64\n".to_string(),
    };
    if let Err(error) = stream.write_all(response.as_bytes()) {
        eprintln!("Ошибка отправки: {error}");
    }
}

fn run_server(address: &str) -> std::io::Result<()> {
    let listener = TcpListener::bind(address)?;
    println!("Сервер слушает {address}");

    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                thread::spawn(|| handle_client(stream));
            }
            Err(error) => eprintln!("Ошибка подключения: {error}"),
        }
    }

    Ok(())
}

fn run_client(address: &str, value: &str) -> std::io::Result<()> {
    let mut stream = TcpStream::connect(address)?;
    stream.write_all(format!("{value}\n").as_bytes())?;
    let mut response = String::new();
    BufReader::new(stream).read_line(&mut response)?;
    println!("Ответ сервера: {}", response.trim());
    Ok(())
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 3 {
        eprintln!("Использование: server|client АДРЕС [ЧИСЛО]");
        std::process::exit(1);
    }

    let result = if args[1] == "server" {
        run_server(&args[2])
    } else if args[1] == "client" && args.len() == 4 {
        run_client(&args[2], &args[3])
    } else {
        eprintln!("Неверные аргументы");
        std::process::exit(1);
    };

    if let Err(error) = result {
        eprintln!("Ошибка: {error}");
        std::process::exit(1);
    }
}
