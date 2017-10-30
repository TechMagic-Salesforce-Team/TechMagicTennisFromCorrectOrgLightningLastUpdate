@isTest
global class MockHttpSignInWithGoogle implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        response.setStatusCode(200);
        return response;
    }
}