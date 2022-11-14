import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import helmet from 'helmet';
import { json, urlencoded } from 'express';
import 'dotenv/config';
import { GlobalInterceptor } from './@core/interceptor/GlobalInterceptor';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  app.setGlobalPrefix('api/v1');
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));
  app.use(helmet());
  app.use(json({ limit: '50mb' }));
  app.use(urlencoded({ extended: true, limit: '50mb' }));
  app.useGlobalInterceptors(new GlobalInterceptor());

  const PORT = process.env.PORT || 3000;
  await app.listen(PORT || 3000);
  console.info(
    'Kilroy Blockchain Connector',
    `Server running on 🚀 http://localhost:${PORT}`,
  );
}
bootstrap();
