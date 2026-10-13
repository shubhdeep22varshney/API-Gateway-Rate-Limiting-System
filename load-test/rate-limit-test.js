import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: 20,
  duration: '30s',
};

export function setup() {
  const res = http.post(
    'http://localhost:8180/realms/api-gateway-realm/protocol/openid-connect/token',
    {
      grant_type: 'password',
      client_id: 'api-gateway-client',
      client_secret: 'YOUR_CLIENT_SECRET',
      username: 'testuser',
      password: 'test123',
    }
  );
  if (res.status !== 200) {
    throw new Error(`Token request failed: ${res.status} ${res.body}`);
  }
  return { token: res.json('access_token') };
}

export default function (data) {
  const res = http.get('http://localhost:8082/demo/hello', {
    headers: {
      Authorization: `Bearer ${data.token}`,
      'client-id': `fake-${__VU}-${__ITER}`,
    },
  });
  check(res, {
    'allowed (200)': (r) => r.status === 200,
    'rate limited (429)': (r) => r.status === 429,
  });
}