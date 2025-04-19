use zero2prod::run;

// Launch application in the background
fn spawn_app() {
    let server = run().expect("Failed to bind address");
    let _ = tokio::spawn(server);
}

#[tokio::test]
async fn health_check_works() {
    // arrange
    spawn_app();
    // bring in `request` to perform HTTP requests against our app
    let client = reqwest::Client::new();
    // act
    let response = client
        .get("http://127.0.0.1:8080/health_check")
        .send()
        .await
        .expect("Failed to send request");
    // assert
    assert!(response.status().is_success());
    assert_eq!(Some(0), response.content_length());
}
