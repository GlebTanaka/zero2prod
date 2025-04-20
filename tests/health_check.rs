use std::net::TcpListener;
use zero2prod::run;

// Launch application in the background
fn spawn_app() -> String {
    let listener = TcpListener::bind("127.0.0.1:0").expect("Failed to bind address");
    // we retrieve the port from the listener assigned by the OS
    let port = listener.local_addr().unwrap().port();
    let server = run(listener).expect("Failed to bind address");
    let _ = tokio::spawn(server);
    // we return the application address to the caller
    format!("http://127.0.0.1:{}", port)
}

#[tokio::test]
async fn health_check_works() {
    // arrange
    let address = spawn_app();
    let client = reqwest::Client::new();

    // act
    let response = client
        // use the address returned by the application
        .get(&format!("{}/health_check", &address))
        .send()
        .await
        .expect("Failed to send request");

    // assert
    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}
